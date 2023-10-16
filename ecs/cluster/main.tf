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

resource "aws_iam_policy" "ecr_deploy_policy" {
  name = "ECRUserPolicy"

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
          "ecr:CompleteLayerUpload",
          "ecr:GetAuthorizationToken"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy" "ecs_deploy_policy" {
  name = "ECSDeployUserPolicy"

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
        Resource = "*"
      }
    ]
  })
}

data "tls_certificate" "github" {
  url = "https://token.actions.githubusercontent.com/.well-known/openid-configuration"
}

resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  thumbprint_list = [data.tls_certificate.github.certificates[0].sha1_fingerprint]
  client_id_list  = ["sts.amazonaws.com"]
}

data "aws_iam_policy_document" "github_actions_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.account_id}:root"]
    }
  }

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type = "Federated"
      identifiers = ["arn:aws:iam::${var.account_id}:oidc-provider/token.actions.githubusercontent.com"]
    }

    condition {
      test      = "StringEquals"
      variable  = "token.actions.githubusercontent.com:aud"
      values    = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = [
        "repo:${var.repo}:*",
      ]
    }
  }
}

resource "aws_iam_role" "deployer-role" {
  name                = "github-ecs-deployer-role"

  assume_role_policy  = data.aws_iam_policy_document.github_actions_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "deployer-role-ecs" {
  role        = aws_iam_role.deployer-role.name
  policy_arn  = aws_iam_policy.ecs_deploy_policy.arn
}

resource "aws_iam_role_policy_attachment" "deployer-role-ecr" {
  role        = aws_iam_role.deployer-role.name
  policy_arn  = aws_iam_policy.ecr_deploy_policy.arn
}

# Give the user direct permissions as well
resource "aws_iam_user_policy" "deployer-user-ecr" {
  name            = "deployer-user-ecr-policy"
  user            = aws_iam_user.cluster_deployer.name
  policy          = aws_iam_policy.ecr_deploy_policy.policy
}
 
resource "aws_iam_user_policy" "deployer-user-ecs" {
  name            = "deployer-user-ecs-policy"
  user            = aws_iam_user.cluster_deployer.name
  policy          = aws_iam_policy.ecs_deploy_policy.policy
}
