variable "account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "account_alias" {
  description = "Name of the Account"
  type        = string
}

variable "cluster_name" {
  description = "Name of EKS Cluster"
  type        = string
}

variable "env" {
  description = "Deployment Environment"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-2"
}

variable "subnet_ids" {
  description = "AWS Subnet Ids"
  type        = list(string)
}

variable "vpc_id" {
  description = "AWS VPC ID"
  type        = string
}

# Node Groups
variable "node_groups" {
  description = "List of Node Groups for the Account"
  type        = map(object({
    name            = string
    instance_types  = list(string)
    min_size        = number
    max_size        = number
    desired_size    = number
    capacity_type   = string
  }))
}

variable "node_group_ssh_access" {
  description = "List of IP Addresses to grant SSH Access to the node group"
  type        = list(string)
}

# User Info
variable "system_masters" {
  description = "List of AWS User Names to give system access to"
  type        = list(string)
}