variable "account_id" {
  description = "AWS Account ID"
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
  description = "List of AWS User Names to give system master access to"
  type        = list(string)
}

variable "deployer_users" {
  description = "List of AWS User Names create a user in K8S for"
  type        = list(string)
  default     = []
}

# Role Info
variable "system_master_roles" {
  description = "List of the role name and user to give system master access to"
  type        = list(object({
    name      = string
    user      = string
  }))
  default     = []
}

variable "deployer_roles" {
  description = "List of the role name and user to give deployer access to"
  type        = list(object({
    name      = string
    user      = string
  }))
  default     = []
}
