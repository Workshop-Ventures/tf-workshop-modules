# Use terraform output to display connection strings.
output "connection_strings" {
  value = mongodbatlas_cluster.main.connection_strings.0.standard_srv
}