variable "endpoint" {
  type = string
}

variable "pve_username" {
  type      = string
  sensitive = true
  ephemeral = true
}

variable "pve_password" {
  type      = string
  sensitive = true
  ephemeral = true
}