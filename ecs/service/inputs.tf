variable "cluster_arn" {
  description = "The ARN of the ECS Cluster"
  type        = string
}

variable "dns_record_name" {
  description = "DNS Record Name"
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

