terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "3.0.1-rc3"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.0"
    }
  }
}

variable "pm_url" {
  type = string
}
variable "pm_token" {
  type      = string
  sensitive = true
}
variable "pm_secret" {
  type      = string
  sensitive = true
}
variable "inventory_username" {
  type      = string
  sensitive = true
}
variable "inventory_password" {
  type      = string
  sensitive = true
}

provider "http" {}

data "http" "inventory_token" {
  url = "https://inventory.markaplay.net/v1/token"

  method = "POST"

  request_headers = {
    Content-Type = "application/json"
  }

  request_body = jsonencode({
    username = "${var.inventory_username}"
    password = "${var.inventory_password}"
  })
}

locals {
  auth_response = jsondecode(data.http.inventory_token)
  token = local.auth_response.token
}

data "http" "inventory" {
  url = "https://inventory.markaplay.net/v1/entities?format=terraform"

  request_headers = {
    Authorization = "Bearer ${token}"
  }
}

locals {
  vmsjson = jsondecode(data.http.inventory)
  vms     = [for v in vmsjson : v if v.resources.host == "apollo3"]
}

provider "proxmox" {
  pm_api_url          = var.pm_url
  pm_api_token_id     = var.pm_token
  pm_api_token_secret = var.pm_secret
  pm_tls_insecure     = true
}

module "qemu-instance" {
  source = "./modules/qemu"
  # insert required variables here
  for_each  = local.vms
  name      = each.value.name
  node      = each.value.node
  image     = each.value.image
  tags      = each.value.tags
  cicustom  = each.value.cicustom
  cores     = each.value.cores
  sockets   = each.value.sockets
  numa      = each.value.numa
  memory    = each.value.memory
  ip        = each.value.ip
  bridge    = each.value.bridge
  os_disk   = each.value.os_disk
  data_disk = each.value.data
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