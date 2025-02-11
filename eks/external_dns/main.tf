################
# EXTERNAL DNS #
################
data "aws_iam_policy_document" "external-dns" {
  statement {
    sid = "1"

    actions = [
      "route53:ChangeResourceRecordSets",
    ]

    resources = [
      "arn:aws:route53:::hostedzone/*",
    ]
  }

  statement {
    actions = [
      "route53:ListHostedZones",
      "route53:ListResourceRecordSets",
    ]

    resources = [
      "*"
    ]
  }
}

resource "aws_iam_policy" "external-dns" {
  name        = "${var.cluster_name}-external-dns-policy"
  description = "External DNS Policy"
  path        = "/"
  policy      = data.aws_iam_policy_document.external-dns.json
}


resource "aws_iam_role" "ext_dns_role" {
  name               = "${var.cluster_name}-external-dns-role"
  assume_role_policy = <<POLICY
{
  "Version":"2012-10-17",
  "Statement": [
    {
      "Effect":"Allow",
      "Principal": {
        "Federated":"arn:aws:iam::${var.account_id}:oidc-provider/${var.oidc_url}"
      },
      "Action":"sts:AssumeRoleWithWebIdentity",
      "Condition": {
       "StringEquals": {
          "${var.oidc_url}:sub": ["system:serviceaccount:kube-system:external-dns-ext", "system:serviceaccount:kube-system:external-dns-int"],
          "${var.oidc_url}:aud": "sts.amazonaws.com"
        }
      }
    }
  ]
}
POLICY
}


resource "aws_iam_role_policy_attachment" "ext_dns_policy_attachment" {
  policy_arn = aws_iam_policy.external-dns.arn
  role       = aws_iam_role.ext_dns_role.name
}

###########################################################
# External-DNS Helm Chart EXT
###########################################################
resource "helm_release" "external_dns_ext" {
  chart     = "external-dns"
  name      = "external-dns-ext"
  namespace = "kube-system"

  repository = "oci://registry-1.docker.io/bitnamicharts"

  values = [templatefile("${path.module}/templates/values.yaml.tpl", {
    role_arn  = aws_iam_role.ext_dns_role.arn,
    scheme    = "internet-facing",
    zone_type = "public"
  })]
}

output external_dns_arn {
  description = "External DNS ARN"
  value = aws_iam_policy.external-dns.arn
}