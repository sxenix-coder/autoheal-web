variable "name_prefix" {
  description = "Prefix applied to all resource names in this module."
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC the security groups belong to."
  type        = string
}

variable "allowed_http_cidr" {
  description = "CIDR permitted to reach the ALB on port 80."
  type        = string
}
