variable "endpoint" {
  type = string
}

variable "pve_node_name" {
  type    = string
  default = "pve"
}

variable "pve_username" {
  type      = string
  sensitive = true
}

variable "pve_password" {
  type      = string
  sensitive = true
}

variable "ct_password" {
  type      = string
  sensitive = true
}