variable env {
  description = "Name of the environment"
  type        = string
}

variable dns_record_name {
  description = "Base DNS Record Name i.e mysite.com"
  type        = string
}

variable region {
  description = "AWS Region for your cluster, used in the DNS name"
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
  root_domain_name                    = "${var.env}.${var.dns_record_name}"
  full_domain_name                    = "${var.region}.${local.root_domain_name}"
  distinct_resource_record_names_ext  = distinct(try(aws_acm_certificate.cert_ext.domain_validation_options[*].resource_record_name, []))
  distinct_resource_record_values_ext = distinct(try(aws_acm_certificate.cert_ext.domain_validation_options[*].resource_record_value, []))

  local_tags = {
    Name = "star.eks.${local.full_domain_name}"
  }
  tags = merge({}, local.local_tags)
}