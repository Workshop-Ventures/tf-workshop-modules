##########################################
# Defaulted Variables
##########################################
variable "tags" {
  description = "Map of tags to tag AWS resources"
  type        = map(string)
  default     = {}
}

##########################################
# Variables
##########################################
variable "account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "api_server_endpoint" {
  description = "Endpoint for your Kubernetes API server"
  type        = string
}

variable "cluster_name" {
  description = "Full name for EKS cluster <env>-<region>-<team>-<cluster_suffix>"
  type        = string
}

variable "oidc_url" {
  description = "OIDC Provider Url"
  type        = string
}

variable "subnet_ids" {
  description = "List of the Private subnet IDs"
  type        = list(any)
}

variable "region" {
  description = "AWS Account Region"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID the cluster lives in. Passed to the aws-load-balancer-controller chart so it doesn't need to query EC2 IMDS (which is often blocked from pods)."
  type        = string
}
