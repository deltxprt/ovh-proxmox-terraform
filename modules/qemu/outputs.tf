output "id" {
  value = proxmox_vm_qemu.qemu_vm.id
}

output "ip_address" {
  value = replace(split(",", proxmox_vm_qemu.qemu_vm.ipconfig0)[0], "ip=", "")
}