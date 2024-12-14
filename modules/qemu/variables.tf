variable "name" {
  type = string
}
variable "node" {
  type = string
  default = "epyc01"
}
variable "image" {
  type = string
}
variable "bios" {
  type = string
  default = "ovmf"
}
variable "tags" {
  type = string
}
variable "cicustom" {
  type = string
}
variable "cores" {
  type = number
  default = 1
}
variable "sockets" {
  type = number
  default = 2
}
variable "numa" {
  type = number
  default = 1
}
variable "memory" {
  type = number
}
variable "ip" {
  type = object({
    address = string
    gateway = string
  })
  validation {
    condition     = can(regex("(^10\\.)|(^172\\.1[6-9]\\.)|(^172\\.2[0-9]\\.)|(^172\\.3[0-1]\\.)|(^192\\.168\\.)", var.ip.address))
    error_message = "IP address is not within the private ranges"
  }
  validation {
    condition     = can(regex("(^10\\.)|(^172\\.1[6-9]\\.)|(^172\\.2[0-9]\\.)|(^172\\.3[0-1]\\.)|(^192\\.168\\.)", var.ip.gateway))
    error_message = "IP gateway is not within the private ranges"
  }
}

variable "bridge" {
  type = string
  default = "private"
}
variable "card_model" {
  type = string
  default = "virtio"
}
variable "firewall" {
  type = bool
  default = true
}

variable "controller" {
  type = string
  default = "virtio-scsi-single"
}
variable "os_disk" {
  type = object({
      backup  = number
      storage = string
      size    = string
    })
  default = {
    backup = 1
    storage = "data01"
    size = "10G"
  }
}

variable "cloudinit_storage" {
  type = string
  default = "data"
}

variable "data_disk" {
  type = object({
      backup  = number
      storage = string
      size    = string
    })
  default = {
    backup = 1
    storage = "local"
    size = "10G"
  }
}