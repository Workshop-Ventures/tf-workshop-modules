replicas: 3
txtOwnerId: "external-dns"
policy: upsert-only
aws:
  zoneType: ${zone_type}
  region: ${region}
annotationFilter: alb.ingress.kubernetes.io/scheme in (${scheme})
rbac:
  create: true
serviceAccount:
  annotations:
    eks.amazonaws.com/role-arn: "${role_arn}"
  apiVersion: v1beta1
  pspEnabled: false