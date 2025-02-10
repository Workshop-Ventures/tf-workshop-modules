resource "helm_release" "metrics_server" {
  chart      = "metrics-server"
  name       = "metrics-server"
  namespace  = "kube-system"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  version    = var.chart_version

  set {
    name  = "image.tag"
    value = var.container_version
  }

  dynamic "set" {
    for_each = {
      "resources.requests.cpu"    = "100m"
      "resources.requests.memory" = "200Mi"
    }
    content {
      name  = set.key
      value = set.value
    }
  }
}