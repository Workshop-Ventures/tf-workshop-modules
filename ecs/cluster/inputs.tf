variable "account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "cluster_name" {
  description = "Name of the ECS Cluster"
  type        = string
}

variable "env" {
  description = "Deployment Environment"
  type        = string
}


variable "repo" {
  description = "Name of the Github Repo to deploy from"
  type        = string
}