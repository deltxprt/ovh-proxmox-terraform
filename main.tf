terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "3.0.1-rc3"
    }
    hcp = {
      source  = "hashicorp/hcp"
      version = "0.94.1"
    }
  }
}

variable "pm_url" {
  type = string
}
variable "pm_token" {
  type = string
}
variable "pm_secret" {
  type = string
}
variable "hcp_cid" {
  type = string
}
variable "hcp_secret" {
  type = string
}

provider "hcp" {
  client_id     = var.hcp_cid
  client_secret = var.hcp_secret
}

provider "proxmox" {
  pm_api_url          = var.pm_url
  pm_api_token_id     = var.pm_token
  pm_api_token_secret = var.pm_secret
}

locals {
  vms_files  = fileset(".", "qemu/*.yaml")
  vms        = { for file in local.vms_files : basename(file) => yamldecode(file(file)) }
  lxcs_files = fileset(".", "lxc/*.yaml")
  lxcs       = { for file in local.lxcs_files : basename(file) => yamldecode(file(file)) }
}



#module "lxc-instance" {
#  source  = "./modules/lxc"
#  for_each = local.lxcs
#  specs {
#    name = "${each.specs.name}"
#    node = "${each.specs.node}"
#    image = "${each.specs.image}"
#    tags = "${each.specs.tags}"
#  }
#  cpu {
#    cores = each.cpu.cores
#    sockets = each.cpu.sockets
#    numa = each.cpu.numa
#  }
#  memory = each.memory
#  network {
#    ip_address = "${each.network.ip_address}"
#    ip_gateway = "${each.network.ip_gateway}"
#    bridge = "${each.network.bridge}"
#    card_model = "virtio"
#    firewall = false
#    dns = "lab.markaplay.net"
#  }
#  disks {
#    bootdrive {
#      size = "${each.disks.bootdrive.size}"
#    }
#    data {
#      size = "${each.disks.data.size}"
#    }
#  }
#  # insert required variables here
#}

module "qemu-instance" {
  source = "./modules/qemu"
  # insert required variables here
  for_each = local.vms
  name = each.value.name
  node = each.value.node
  image = each.value.image
  tags = each.value.tags
  cicustom = each.value.cicustom
  cores = each.value.cores
  sockets = each.value.sockets
  numa = each.value.numa
  memory = each.value.memory
  ip = each.value.ip
  bridge = each.value.bridge
  os_disk = each.value.os_disk
  data_disk = each.value.data
}