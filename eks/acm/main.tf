resource "aws_acm_certificate" "cert_ext" {
  domain_name       = "*.eks.${local.full_domain_name}"
  validation_method = "DNS"

  tags = local.tags

  lifecycle {
    # This is a placeholder while work is still in progress.  Will eventually be changed to true.
    prevent_destroy = false
    ignore_changes = [
      tags,
    ]
  }
}

resource "aws_route53_record" "cert_validation_ext" {
  # Terraform can't `count` off resources which don't exist yet.
  # Wildcards also get the same validation record as their non-wildcard parent.
  # Deduplicate all SANs after stripping a leading "*." from each one.
  # https://github.com/simplisafe/tf-ecs-modules/blob/master/multi-acc/acm/main.tf#L29
  count   = length(distinct([for san in flatten(["*.eks.${local.full_domain_name}"]) : replace(san, "/^\\*\\./", "")]))
  name    = local.distinct_resource_record_names_ext[count.index]
  type    = "CNAME"
  zone_id = var.zone_id
  records = [local.distinct_resource_record_values_ext[count.index]]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "cert_ext" {
  certificate_arn         = aws_acm_certificate.cert_ext.arn
  validation_record_fqdns = aws_route53_record.cert_validation_ext.*.fqdn
}