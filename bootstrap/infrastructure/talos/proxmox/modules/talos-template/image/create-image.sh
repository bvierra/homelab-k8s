#!/usr/bin/env bash
req_commands=("curl" "xz" "qemu-img")
for cmd in "${req_commands[@]}"; do
  if ! command -v "$cmd" &> /dev/null; then
    echo "$cmd could not be found, please install it."
    exit 1
  fi
done

mkdir -p /tmp/talos-images

# Verify if QCOW2 image already exists, which means it has already been downloaded and converted
if [ -f "/tmp/talos-images/${TALOS_LOCAL_FILE_QCOW}" ]; then
  echo "Talos ${TALOS_VERSION} QCOW2 image already exists, skipping download."
  exit 0
fi

# Download if not already present
if [ ! -f "/tmp/talos-images/${TALOS_LOCAL_FILE}" ]; then
  echo "Downloading Talos ${TALOS_VERSION} Schematic ID: ${TALOS_SCHEMATIC_ID}..."
  curl -fsSL "${TALOS_IMAGE_URL}" \
    -o "/tmp/talos-images/${TALOS_LOCAL_FILE_XZ}"

  echo "Decompressing Talos image..."
  if [ -f "/tmp/talos-images/${TALOS_LOCAL_FILE_XZ}" ]; then
    xz -d "/tmp/talos-images/${TALOS_LOCAL_FILE_XZ}"
  else
    echo "Failed to download Talos image"
    exit 1
  fi
else
  echo "Talos ${TALOS_VERSION} already downloaded"
fi

# Convert to QCOW2 format if not already present
if [ ! -f "/tmp/talos-images/${TALOS_LOCAL_FILE_QCOW}" ]; then
  echo "Converting Talos image to QCOW2 format..."
  qemu-img convert -f raw -O qcow2 "/tmp/talos-images/${TALOS_LOCAL_FILE}" "/tmp/talos-images/${TALOS_LOCAL_FILE_QCOW}"
  ret=$?
  if [ $ret -ne 0 ]; then
    echo "Failed to convert Talos image to QCOW2 format"
    exit 1
  else
    rm -f "/tmp/talos-images/${TALOS_LOCAL_FILE}"
    echo "Talos image converted to QCOW2 format successfully"
  fi

  echo "Resizing Talos image to 10G..."
  qemu-img resize '--preallocation=metadata' "/tmp/talos-images/${TALOS_LOCAL_FILE_QCOW}" 10G
  ret=$?
  if [ $ret -ne 0 ]; then
    echo "Failed to resize Talos image to 10G"
    exit 1
  else
    rm -f "/tmp/talos-images/${TALOS_LOCAL_FILE}"
    echo "Talos image resized successfully"
  fi

else
  echo "Local Talos ${TALOS_VERSION} QCOW2 image already exists"
fi

echo "Step 1: Uploading Talos image via rsync..."

# Use rsync for reliable large file transfer with progress
rsync --no-p --no-o --no-g -vz --progress "/tmp/talos-images/${TALOS_LOCAL_FILE_QCOW}" \
  "root@${PROXMOX_NODE}:${PVE_IMAGE_IMPORT_FILENAME}"

ret=$?
if [ $ret -ne 0 ]; then
  echo "Failed to upload Talos image to Proxmox VE node"
  exit 1
else
  echo "Talos image uploaded successfully"
fi

