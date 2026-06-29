# To avoid CT lock error when provisioning containers, don't use parralelism (set parralelism to 1)
# terraform apply -parallelism=1

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

resource "proxmox_virtual_environment_container" "alpine_template" {
  node_name     = var.pve_node_name
  template      = true
  started       = false
  start_on_boot = false

  unprivileged = true
  features {
    nesting = true
  }

  initialization {
    dns {
      servers = ["1.1.1.1"]
    }
    user_account {
      password = var.ct_password
    }
  }

  network_interface {
    bridge   = "vmbr0"
    firewall = false
    name     = "eth0"
  }

  cpu {
    cores = 1
  }

  memory {
    dedicated = 512
  }

  disk {
    datastore_id = "local-lvm"
    size         = 1
  }

  operating_system {
    template_file_id = proxmox_download_file.alpine_3-23_lxc_img.id
    type             = "alpine"
  }
}

resource "proxmox_download_file" "alpine_3-23_lxc_img" {
  content_type = "vztmpl"
  datastore_id = "local"
  node_name    = var.pve_node_name
  url          = "http://download.proxmox.com/images/system/alpine-3.23-default_20260116_amd64.tar.xz"
}


resource "proxmox_virtual_environment_container" "worker_1" {
  node_name     = var.pve_node_name
  template      = false
  started       = true
  start_on_boot = true

  clone {
    vm_id = proxmox_virtual_environment_container.alpine_template.vm_id
  }

  initialization {
    hostname = "worker-1"
    ip_config {
      ipv4 {
        address = "192.168.200.2/24"
        gateway = "192.168.200.1"
      }
    }
  }
}

resource "proxmox_virtual_environment_container" "worker_2" {
  node_name     = var.pve_node_name
  template      = false
  started       = true
  start_on_boot = true

  clone {
    vm_id = proxmox_virtual_environment_container.alpine_template.vm_id
  }

  initialization {
    hostname = "worker-2"
    ip_config {
      ipv4 {
        address = "192.168.200.3/24"
        gateway = "192.168.200.1"
      }
    }
  }
}

resource "proxmox_virtual_environment_container" "worker_3" {
  node_name     = var.pve_node_name
  template      = false
  started       = true
  start_on_boot = true

  clone {
    vm_id = proxmox_virtual_environment_container.alpine_template.vm_id
  }

  initialization {
    hostname = "worker-3"
    ip_config {
      ipv4 {
        address = "192.168.200.4/24"
        gateway = "192.168.200.1"
      }
    }
  }
}

resource "proxmox_virtual_environment_container" "load_balancer" {
  node_name     = var.pve_node_name
  template      = false
  started       = true
  start_on_boot = true

  clone {
    vm_id = proxmox_virtual_environment_container.alpine_template.vm_id
  }

  initialization {
    hostname = "load-balancer"
    ip_config {
      ipv4 {
        address = "192.168.200.5/24"
        gateway = "192.168.200.1"
      }
    }
  }
}