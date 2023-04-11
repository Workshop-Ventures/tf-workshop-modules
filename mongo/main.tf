terraform {
  required_providers {
    mongodbatlas = {
      source = "mongodb/mongodbatlas"
    }
  }
}

resource "mongodbatlas_project" "main" {
  name   = var.atlas_project_name
  org_id = var.atlas_org_id
}

resource "mongodbatlas_cluster" "cluster" {
  project_id = mongodbatlas_project.main.id
  name       = var.cluster_name

  # Provider Settings "block"
  provider_name = "TENANT"

  # options: AWS AZURE GCP
  backing_provider_name = "AWS"

  # options: M2/M5 atlas regions per cloud provider
  # GCP - CENTRAL_US SOUTH_AMERICA_EAST_1 WESTERN_EUROPE EASTERN_ASIA_PACIFIC NORTHEASTERN_ASIA_PACIFIC ASIA_SOUTH_1
  # AZURE - US_EAST_2 US_WEST CANADA_CENTRAL EUROPE_NORTH
  # AWS - US_EAST_1 US_WEST_2 EU_WEST_1 EU_CENTRAL_1 AP_SOUTH_1 AP_SOUTHEAST_1 AP_SOUTHEAST_2
  provider_region_name = upper(var.region)

  # options: M0 M2 M5
  provider_instance_size_name = var.cluster_instance_size

  # Will not change till new version of MongoDB but must be included
  mongo_db_major_version       = "6.0"
  auto_scaling_disk_gb_enabled = "false"

  # lifecycle {
  #   prevent_destroy = true
  # }
}

#
# Create an Atlas Admin Database User
#
resource "mongodbatlas_database_user" "admin" {
  username = var.mongodb_admin_user
  password = var.mongodb_admin_pass

  project_id         = mongodbatlas_project.main.id
  auth_database_name = "admin"

  roles {
    role_name     = "atlasAdmin"
    database_name = "admin"
  }
}

#
# Create an IP Accesslist
#
# can also take a CIDR block or AWS Security Group -
# replace ip_address with either cidr_block = "CIDR_NOTATION"
# or aws_security_group = "SECURITY_GROUP_ID"
resource "mongodbatlas_project_ip_access_list" "access" {
  for_each = var.access_list

  project_id = mongodbatlas_project.main.id
  ip_address = each.value.ip_address
  comment    = each.value.comment
}
