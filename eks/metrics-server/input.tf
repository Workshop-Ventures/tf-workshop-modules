variable "api_server_endpoint" {
  description = "Endpoint for your Kubernetes API server"
  type        = string
}

variable "chart_version" {
  description = "Version of the metrics server Helm chart to install."
  type        = string
}

variable "container_version" {
  description = "Version of the metrics server image to install."
  type        = string
}