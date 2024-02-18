variable "kubernetes_version" {
  type     = string
  nullable = false
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private subnets ids"
  nullable    = false
}

variable "vpc_id" {
  type     = string
  nullable = false
}

variable "ssh_key_name" {
  type = string
}
