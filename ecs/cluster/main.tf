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

// cluster deployer user
resource "aws_iam_user" "cluster_deployer" {
  name = "${var.env}-${var.cluster_name}-deployer"
}

resource "aws_iam_user_policy" "ecr_user_policy" {
  name = "ECRUserPolicy"
  user = aws_iam_user.cluster_deployer.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_user_policy" "ecs_deploy_user_policy" {
  name = "ECSDeployUserPolicy"
  user = aws_iam_user.cluster_deployer.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "ecs:RegisterTaskDefinition",
          "ecs:DeregisterTaskDefinition",
          "ecs:ListTaskDefinitions",
          "ecs:DescribeTaskDefinition",
          "ecs:RunTask",
          "ecs:StartTask",
          "ecs:StopTask",
          "ecs:DescribeTasks",
          "ecs:ListTasks",
          "ecs:UpdateService",
          "ecs:DescribeServices",
          "ecs:CreateService",
          "ecs:DeleteService"
        ],
        Resource = aws_ecs_cluster.main.arn
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "ecs_deploy_user_policy_attachment" {
  user       = aws_iam_user.cluster_deployer.name
  policy_arn = aws_iam_user_policy.ecs_deploy_user_policy.arn
}

resource "aws_iam_user_policy_attachment" "ecr_user_policy_attachment" {
  user       = aws_iam_user.cluster_deployer.name
  policy_arn = aws_iam_user_policy.ecr_user_policy.arn
}

