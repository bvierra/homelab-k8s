#!/usr/bin/env bash

shopt -s globstar

SCRIPT_DIR=$(dirname -- "$(readlink -f "${BASH_SOURCE[0]}")")
ROOT_DIR=$(readlink -f "$SCRIPT_DIR"/..)
ARTIFACTS_DIR="$ROOT_DIR/artifacts"

[ ! -d "$ARTIFACTS_DIR" ] || mkdir -p "$ARTIFACTS_DIR"
[ ! -d "$ARTIFACTS_DIR/sops" ] || mkdir -p "$ARTIFACTS_DIR/sops"

ACTION=""
USERNAME=false
FORCE=0

generate_key() {
  local key_type key_name key_file pub_file
  key_type=${1:-"server"}
  key_name=${2:-"default"}
  if [[ "$key_type" != "server" && "$key_type" != "user" ]]; then
    echo "Invalid key type. Use 'server' or 'client'."
    exit 1
  fi

  if [[ $key_type =~ "server" ]]; then
    # if we are making a server key, just check if the dir exists and if so error out
    key_dir="$ARTIFACTS_DIR/sops/server"
    key_file="$ARTIFACTS_DIR/sops/server/server.privkey"
    pub_file="$ARTIFACTS_DIR/sops/server/server.pubkey"
  elif [[ $key_type =~ "user" ]]; then
    # if we are making a user key and no username was specified then we name the dir user otherwise user-<key_name>
    # if dir already exists then error out
    if [[ $key_name =~ "default" ]]; then
      key_dir="$ARTIFACTS_DIR/sops/user"
      key_file="$key_dir/user.privkey"
      pub_file="$key_dir/user.pubkey"
    else
      key_dir="$ARTIFACTS_DIR/sops/user-$key_name"
      key_file="$key_dir/user-$key_name/user-$key_name.privkey"
      pub_file="$key_dir/user-$key_name/user-$key_name.pubkey"
    fi
  fi
  if [[ -d "$key_dir" ]]; then
    echo "SOPS key already exist at $key_dir"
    exit 1
  else
    mkdir -p "$key_dir"
  fi

  age-keygen -o "$key_file"
  pub=$(cat "$key_file" | grep public | awk -F': ' '{print $2}' | tr -d '\n')
  echo "$pub" > "$pub_file"
  echo "SOPS Private key saved to $key_file"
  echo "SOPS Public key saved to $pub_file"
}

export_secret_key_to_k8s() {
  if [[ ! -f "$ARTIFACTS_DIR/sops/server/server.privkey" ]]; then
    echo "SOPS age key not found at $ARTIFACTS_DIR/sops/server/server.privkey"
    exit 1
  fi

  if [ "$(kubectl get secret/sops-age -n flux-system)" ]; then
    if get_confirmation "Secret sops-age already exists in flux-system namespace. Do you want to overwrite it?"; then
      kubectl delete secret sops-age -n flux-system
    fi
  fi

  kubectl create secret generic sops-age \
    --namespace=flux-system \
    --from-file=sops.agekey="$ARTIFACTS_DIR"/sops/server/server.privkey

  kubectl annotate \
    --namespace=flux-system \
    --overwrite=true \
    secret sops-age \
    reflector.v1.k8s.emberstack.com/reflection-allowed="true"

  kubectl annotate \
    --namespace=flux-system \
    --overwrite=true \
    secret sops-age \
    reflector.v1.k8s.emberstack.com/reflection-allowed-namespaces=""

  echo "Secret 'sops-age' created/updated in 'flux-system' namespace"
}

create_sops_config() {
  local -a pub_keys=()
  for file in "$ARTIFACTS_DIR"/sops/**/*.pubkey; do
    pub_keys+=("$(cat "$file"),")
  done
  PUB_KEY=$(IFS=$'\n'; echo "${pub_keys[*]}" | sed 's/^/      /')
  cat <<EOF > "$ROOT_DIR/.sops.yaml"
creation_rules:
  - encrypted_regex: '^(data|stringData|caBundle)$'
    path_regex: 'manifests/.*\.sops\.ya?ml$'
    age: >-
${PUB_KEY}
  - path_regex: 'talos/.*\.sops\.ya?ml$'
    age: >-
${PUB_KEY}
  - path_regex: '.*-secret\.sops\.ya?ml$'
    age: >-
${PUB_KEY}
EOF
}

delete_sops_keys() {
  rm -rf "$ARTIFACTS_DIR/sops"
}

error() {
  echo "Error: $1"
  exit 1
}

get_confirmation() {
  msg="$1"
  if [ $FORCE -eq 0 ]; then
    if [[ -t 0 ]]; then
      read -rp "$msg (y/N): " confirm
    else
      confirm="n"
      echo "Non-interactive shell detected. To confirm deletion, use the --force flag."
    fi
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
      echo "Aborting."
      exit 1
    fi
  fi
}

help() {
  cat << EOF
Usage: $0 [options]

The following actions are mutually exclusive; only one can be specified at a time.
[--clean|--generate-configs|--add-user|--full|--k8s-export-secret]

The --full option will delete any existion SOPS keys, generate a new server key,
generate a new user key, create the .sops.yaml config file, and export the server
key to kubernetes.

Adding a user key with --add-user will also regenerate the .sops.yaml config file.
With the existing server key and all other user keys that have been created.

Options:
  -c, --clean                 Delete all existing SOPS keys.  This action cannot be undone.
  -g, --generate-configs      Generate the .sops.yaml configuration file based on existing keys.
  -a, --add-user [username]   Generate a new user SOPS key. If no username is provided,
                              a default user key will be created.
  -f, --full                  Generate a new server and default user SOPS keys,
                              create the .sops.yaml configuration file, and
                              export the server key to Kubernetes.
  -k, --k8s-export-secret     Export the server SOPS key as a secret to
                              flux-system/sops-age in Kubernetes.
      --force                 Bypass confirmation prompts for destructive actions.
  -h, --help                  Display this help message.
EOF
}

SHORT_OPTS="cga:fkh"
LONG_OPTS="clean,generate-configs,add-user:,full,k8s-export-secret,force,help"

OPTS=$(getopt -o "$SHORT_OPTS" --long "$LONG_OPTS" -n "$0" -- "$@")

# shellcheck disable=SC2181
if [ $? != 0 ] ; then echo "Failed parsing options." >&2 ; exit 1 ; fi

eval set -- "$OPTS"

while true; do
  case "$1" in
    -h | --help)
      break;;
    -c | --clean)
      [ -z "$ACTION" ] || error "Only one action can be specified at a time"
      ACTION="clean"
      shift ;;
    -g | --generate-configs)
      [ -z "$ACTION" ] || error "Only one action can be specified at a time"
      ACTION="generate-configs"
      shift;;
    -a | --add-user )
      [ -z "$ACTION" ] || error "Only one action can be specified at a time"
      ACTION="add-user"
      USERNAME="$2";
      shift 2;;
    -f | --full )
      [ -z "$ACTION" ] || error "Only one action can be specified at a time"
      ACTION="full"
      shift ;;
    -k | --k8s-export-secret )
      [ -z "$ACTION" ] || error "Only one action can be specified at a time"
      ACTION="export-secret"
      shift ;;
    --force)
      FORCE=1;
      shift ;;
    -- )
      shift;
      break ;;
    * )
      break ;;
  esac
done

case "$ACTION" in
  clean)
    if get_confirmation "Are you sure you want to delete all SOPS keys? This action cannot be undone."; then
      delete_sops_keys
    fi
    ;;
  full)
    if [ -d "$ARTIFACTS_DIR/sops" ]; then
      if get_confirmation "SOPS keys already exist. Do you want to delete and regenerate them? This action cannot be undone."; then
        delete_sops_keys
      else
        echo "Aborting."
        exit 1
      fi
    fi
    echo "Generating server key..."
    generate_key "server"
    echo "Generating default user key..."
    generate_key "user"
    echo "Creating .sops.yaml configuration..."
    create_sops_config
    echo "Exporting secret key to Kubernetes..."
    export_secret_key_to_k8s
    ;;
  add-user)
    if [ "$USERNAME" = false ]; then
      generate_key "user"
    else
      generate_key "user" "$USERNAME"
    fi
    create_sops_config
    ;;
  generate-configs)
    create_sops_config
    ;;
  export-secret)
    export_secret_key_to_k8s
    ;;
  *)
    ;;
esac
