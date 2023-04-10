variable env {
  description = "Name of the environment"
  type        = string
}

variable full_dns_name {
  description = "FULL DNS name for the EKS Cluster i.e eks.us-east-1.prd.mysite.com"
  type        = string
}

variable zone_id {
  description = "ID Of the DNS Zone to host your record in"
  type        = string
}


###################
# Local variables #
###################
locals {
  distinct_resource_record_names_ext  = distinct(try(aws_acm_certificate.cert_ext.domain_validation_options[*].resource_record_name, []))
  distinct_resource_record_values_ext = distinct(try(aws_acm_certificate.cert_ext.domain_validation_options[*].resource_record_value, []))

  local_tags = {
    Name = "star.${var.full_domain_name}"
    env = var.env,
  }
  
  tags = merge({}, local.local_tags)
}