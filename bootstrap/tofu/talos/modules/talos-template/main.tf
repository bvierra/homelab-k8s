terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      version = "0.93.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
    talos = {
      source = "siderolabs/talos"
      version = "0.10.1"
    }
  }
}

locals {
  talos_schematic_id        = talos_image_factory_schematic.this.id
  talos_schematic_short_id  = substr(local.talos_schematic_id, -5, -1)
  talos_image_name          = "nocloud-amd64"
  talos_image_extension     = "raw"
  talos_image_name_xz       = "${local.talos_image_name}.${local.talos_image_extension}.xz"
  talos_image_url           = "https://factory.talos.dev/image/${local.talos_schematic_id}/${var.talos_version}/${local.talos_image_name_xz}"
  talos_local_file          = "talos-${var.talos_version}-${local.talos_schematic_short_id}-nocloud-amd64.raw"
  talos_local_file_qcow     = "talos-${var.talos_version}-${local.talos_schematic_short_id}-nocloud-amd64.qcow2"
  talos_local_file_xz       = "talos-${var.talos_version}-${local.talos_schematic_short_id}-nocloud-amd64.raw.xz"
  template_name             = "talos-${var.talos_version}-${local.talos_schematic_short_id}-amd64-template"
  pve_image_import_filename = "${var.proxmox_import_path}/${local.talos_local_file_qcow}"
}

data "talos_image_factory_extensions_versions" "this" {
  # get the latest talos version
  talos_version = var.talos_version
  filters = {
    names = var.talos_image.extensions
  }
}

resource "talos_image_factory_schematic" "this" {
  schematic = yamlencode(
    {
      customization = {
        systemExtensions = {
          officialExtensions = data.talos_image_factory_extensions_versions.this.extensions_info.*.name
        }
        extraKernelArgs = var.talos_image.kernelArgs
      }
    }
  )
}



# resource "proxmox_virtual_environment_download_file" "talos_image" {
#   content_type            = "import"
#   datastore_id            = "${var.vm_storage_pool}"
#   node_name               = "${var.proxmox_node}"
#   url                     = local.talos_image_url
#   decompression_algorithm = "zst"
#   file_name               = local.talos_local_file
# }

# We need to download and decompress the Talos cloud image
resource "null_resource" "download_and_decompress_talos" {
  triggers = {
    talos_version       = var.talos_version
    talos_schematic_id  = local.talos_schematic_id
  }

  # We use a bash file to download, decompress, and then convert the talos image to qcow2
  # We then use ssh to upload the image to Proxmox VE storage via rsync
  # We use rsync because the proxmox_virtual_environment_download resource takes upwards of 10min
  # While rsync does it in much less time

  provisioner "local-exec" {
    command = "${path.module}/image/create-image.sh"
    interpreter = [ "/usr/bin/env","bash" ]
    environment = {
      TALOS_IMAGE_URL           = local.talos_image_url
      TALOS_LOCAL_FILE          = local.talos_local_file
      TALOS_LOCAL_FILE_XZ       = local.talos_local_file_xz
      TALOS_LOCAL_FILE_QCOW     = local.talos_local_file_qcow
      TALOS_VERSION             = var.talos_version
      TALOS_SCHEMATIC_ID        = local.talos_schematic_id
      PVE_IMAGE_IMPORT_FILENAME = local.pve_image_import_filename
      PROXMOX_NODE              = var.proxmox_node
    }
  }
}

# resource "proxmox_virtual_environment_file" "talos_image" {
#   depends_on = [null_resource.download_and_decompress_talos]
#   node_name = var.proxmox_node
#   datastore_id = var.vm_storage_pool
#   content_type = "import"
#   source_file {
#     path = "/tmp/talos-images/${local.talos_local_file_qcow}"
#   }
# }

data "proxmox_virtual_environment_file" "talos_image" {
  depends_on = [null_resource.download_and_decompress_talos]

  node_name   = var.proxmox_node
  datastore_id = var.vm_storage_pool
  content_type = "import"
  file_name     = local.talos_local_file_qcow
}

resource "proxmox_virtual_environment_vm" "talos_template" {
  depends_on = [data.proxmox_virtual_environment_file.talos_image]

  name        = "talos-${var.talos_version}-${local.talos_schematic_short_id}-amd64-template"
  vm_id       = var.template_vm_id
  node_name   = var.proxmox_node
  template    = true

  stop_on_destroy = true

  agent {
    enabled = false
  }

  bios = "seabios"

  boot_order = [ "scsi0" ]

  cpu {
    cores = 2
    type = "host"
    flags = ["+aes"]
  }

  memory {
    dedicated = 2 * 1024
  }

  disk {
    interface     = "scsi0"
    size          = 10
    datastore_id  = var.vm_storage_pool
    # Since the disk is downloaded as compressed we have to use file_id to reference it
    file_id       = data.proxmox_virtual_environment_file.talos_image.id
  }

  machine = "q35"

  network_device {
    bridge = var.template_bridge
    model = "virtio"
  }

  scsi_hardware = "virtio-scsi-single"

  serial_device {
    device = "socket"
  }

  started = false

}
