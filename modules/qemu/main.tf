terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "3.0.1-rc3"
    }
  }
}

resource "proxmox_vm_qemu" "qemu_vm" {
  name        = var.name
  target_node = var.node
  cicustom    = format("user=%s", var.cicustom) #"user=NAS:snippets/user-debian.yml"
  clone       = var.image
  bios        = var.bios
  tags        = var.tags

  cores   = var.cores
  sockets = var.sockets
  numa    = var.numa
  memory  = var.memory

  smbios {
    serial = "ds=nocloud;h=${var.name}"
  }

  # Disks setup
  scsihw = var.controller
  disks {
    virtio {
      virtio0 {
        disk {
          backup  = (var.os_disk.backup == 1 ? true : false)
          storage = var.os_disk.storage
          size    = var.os_disk.size
        }
      }
      virtio1 {
        disk {
          backup  = (var.data_disk.backup == 1 ? true : false)
          storage = var.data_disk.storage
          size    = var.data_disk.size
        }
      }
    }
    ide {
      ide2 {
        cloudinit {
          storage = var.cloudinit_storage
        }
      }
    }
  }

  # networking
  ipconfig0 = format("gw=%s,ip=%s/24", var.ip.gateway, var.ip.address) #"ip=10.0.50.79/24,gw=10.0.50.1"
  network {
    bridge   = var.bridge
    firewall = var.firewall
    model    = var.card_model
  }
}