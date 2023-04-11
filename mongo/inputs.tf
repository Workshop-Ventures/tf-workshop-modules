variable "access_list" {
  description = "MongoDB Access List"
  type        = map(object({
    ip_address = string
    comment    = string
  }))
}

variable "atlas_org_id" {
  description = "Id of the Atlas Org"
  type        = string
}

variable "atlas_project_name" {
  description = "Name of the atlas project"
  type        = string
}

variable "cluster_instance_size" {
  description = "Atlas Cluster Size (M0, M2, M5)"
  type        = string
  default     = "M0"
}

variable "cluster_name" {
  description = "Name of the mongo cluster"
  type        = string 
}

variable "mongodb_admin_user" {
  description = "MongoDB Admin Username"
  type        = string
  sensitive   = true
}

variable "mongodb_admin_pass" {
  description = "MongoDB Admin Password"
  type        = string
  sensitive   = true
}

variable "prevent_destroy" {
  description = "Should we prevent you from destroying the cluster"
  type        = bool
  default     = true
}

variable "region" {
  description = "AWS Region Supported by Atlas"
  type        = string
}