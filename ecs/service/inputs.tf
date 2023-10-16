variable "cluster_arn" {
  description = "The ARN of the ECS Cluster"
  type        = string
}

variable "dns_zone_name" {
  description = "DNS Zone Name"
  type        = string
}

variable "dns_prefix" {
  description = "DNS Record Prefix"
  type        = string
}

variable "env" {
  description = "Deployment Environment"
  type        = string
}

variable "service_name" {
  description = "Name of the ECS Service"
  type        = string
}

variable "service_port" {
  description = "Port of the ECS Service"
  type        = number
}

