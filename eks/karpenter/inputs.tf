variable "enabled" {
  description = "Whether to enable Karpenter"
  type        = bool
  default     = true
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "env" {
  description = "Environment name"
  type        = string
}
