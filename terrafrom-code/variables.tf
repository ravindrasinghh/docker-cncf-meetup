variable "env" {
  type = string
}
##VPC
variable "vpc_conf" {
  type    = map(any)
  default = {}
}
variable "public_subnet" {
  type        = map(any)
  description = "Public Subnets to be created"
}

variable "cluster_name" {
  type = string
}

variable "server_ingress_rules" {
  type = any
}
variable "server_egress_rules" {
  type = any
}

variable "instance_type" {
  type = string
}
variable "ami_id" {
  type = string
}

variable "compatibility" {
  type    = string
  default = "EC2"
}
