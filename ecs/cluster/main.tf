locals {
  ecs_cluster_name = "${var.env}-${var.cluster_name}-cluster"
}

resource "aws_kms_key" "cluster-logs-kms" {
  description             = "${var.env}-${var.cluster_name}-cluster-log-key"
  deletion_window_in_days = 7
}

resource "aws_cloudwatch_log_group" "cluster-logs" {
  name = "${var.env}-${var.cluster_name}-cluster-log-group"
}

resource "aws_ecs_cluster" "main" {
  name = local.ecs_cluster_name

  tags = {
    Name = local.ecs_cluster_name
    Env = var.env
  }

  configuration {
    execute_command_configuration {
      kms_key_id = aws_kms_key.cluster-logs-kms.arn
      logging    = "OVERRIDE"

      log_configuration {
        cloud_watch_encryption_enabled = true
        cloud_watch_log_group_name     = aws_cloudwatch_log_group.cluster-logs.name
      }
    }
  }
}
