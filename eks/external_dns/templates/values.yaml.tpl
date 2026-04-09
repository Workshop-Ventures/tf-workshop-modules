# Values for the official external-dns chart
# https://github.com/kubernetes-sigs/external-dns/tree/master/charts/external-dns
replicaCount: 3
txtOwnerId: "external-dns"
policy: upsert-only

provider:
  name: aws

env:
  - name: AWS_REGION
    value: ${region}

extraArgs:
  - --aws-zone-type=${zone_type}
  - --annotation-filter=alb.ingress.kubernetes.io/scheme in (${scheme})

serviceAccount:
  create: true
  name: external-dns-ext
  annotations:
    eks.amazonaws.com/role-arn: "${role_arn}"

rbac:
  create: true
