terraform {
  required_version = "1.15.6"
  required_providers {
    proxmox = {
      version = "0.111.0"
      source  = "bpg/proxmox"
    }
  }
}

provider "proxmox" {
  endpoint      = var.endpoint
  username      = var.pve_username
  password      = var.pve_password
  insecure      = true
  random_vm_ids = true
}