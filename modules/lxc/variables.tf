variable "specs" {
  type = object({
    name  = string
    node  = string
    image = string
    tags  = string
  })
  validation {
    condition     = can(regex("(^\\w+\\:\\w+\\/\\S+\\.tar\\.gz$)", var.specs.image))
    error_message = "image path not valid must be like 'local:vztmpl/ubuntu-20.04-standard_20.04-1_amd64.tar.gz'"
  }
}

variable "cpu" {
  type = object({
    cores   = number
    sockets = number
    numa    = bool
  })
}

variable "memory" {
  type = number
}

variable "network" {
  type = object({
    ip_address = string
    ip_gateway = string
    bridge     = string
    card_model = string
    firewall   = bool
    dns        = string
  })
  validation {
    condition     = can(regex("(^10\\.)|(^172\\.1[6-9]\\.)|(^172\\.2[0-9]\\.)|(^172\\.3[0-1]\\.)|(^192\\.168\\.)", var.network.ip_address))
    error_message = "IP address is not within the private ranges"
  }
  validation {
    condition     = can(regex("(^10\\.)|(^172\\.1[6-9]\\.)|(^172\\.2[0-9]\\.)|(^172\\.3[0-1]\\.)|(^192\\.168\\.)", var.network.ip_gateway))
    error_message = "IP gateway is not within the private ranges"
  }
}

variable "disks" {
  type = object({
    controller = string
    bootdrive = object({
      backup  = bool
      storage = string
      size    = string
    })
    cloudinit = object({
      storage = string
    })
    data = object({
      backup  = bool
      storage = string
      size    = string
    })
  })
  default = {
    controller = "virtio-scsi-single"
    bootdrive = {
      backup  = true
      storage = "data01"
      size    = "10G"
    }
    cloudinit = {
      storage = "data01"
    }
    data = {
      backup  = true
      storage = "data01"
      size    = "10G"
    }
  }
}