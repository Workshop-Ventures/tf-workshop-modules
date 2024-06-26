# EKS Cluster Module
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.12.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.30"

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access = true

  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"

    attach_cluster_primary_security_group = false

    # Disabling and using externally provided security groups
    create_security_group = false
  }

  enable_irsa = true

  cluster_security_group_additional_rules = {
    ingress_nodes_ephemeral_ports_tcp = {
      description                = "Nodes on ephemeral ports"
      protocol                   = "tcp"
      from_port                  = 1025
      to_port                    = 65535
      type                       = "ingress"
      source_node_security_group = true
    }
  }

  node_security_group_additional_rules = {
    ingress_self_all = {
      description     = "Node to node all ports/protocols"
      protocol        = "-1"
      from_port       = 0
      to_port         = 0
      type            = "ingress"
      self            = true
    }
  }

  # aws-auth configmap
  # create_aws_auth_configmap = true
  manage_aws_auth_configmap = true

  aws_auth_users = concat([
    for user in var.system_masters: 
      {
        userarn   = "arn:aws:iam::${var.account_id}:user/${user}"
        username  = user
        groups    = ["system:masters"] 
      }
  ],
  [
    for user in var.deployer_users:
      {
        userarn  = "arn:aws:iam::${var.account_id}:user/${user}"
        username = user
        groups   = []
      }
  ])

  aws_auth_roles = concat([
    for role in var.system_master_roles:
      {
        rolearn   = "arn:aws:iam::${var.account_id}:role/${role.name}"
        username  = role.user
        groups    = ["system:masters"]
      }
  ],
  [
    for role in var.deployer_roles:
      {
        rolearn   = "arn:aws:iam::${var.account_id}:role/${role.name}"
        username  = role.user
        groups    = []
      }
  ])


  eks_managed_node_groups = {
    for group in var.node_groups:
      group.name => {
        name              = group.name
        instance_types    = group.instance_types
        min_size          = group.min_size
        max_size          = group.max_size
        desired_size      = group.desired_size

        capacity_type     = group.capacity_type

        vpc_security_group_ids = [
          aws_security_group.node_group[group.name].id
        ]
      }
  }

  tags = {
    env        = var.env
    created_by = "Terraform"
  }
}

# Security Groups
resource "aws_security_group" "node_group" {
  for_each = var.node_groups

  name_prefix = each.key
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "ssh_access" {
  for_each = aws_security_group.node_group

  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  security_group_id = each.value.id
  cidr_blocks = var.node_group_ssh_access
}

# Open up the SG to itself on all ports
resource "aws_security_group_rule" "self_access" {
  for_each = aws_security_group.node_group

  type        = "ingress"
  from_port   = 0
  to_port     = 65535
  protocol    = "all"
  security_group_id = each.value.id
  self        = true
}

# Deployer Role
resource "kubernetes_role" "deployer" {
  metadata {
    namespace = "default"
    name      = "deployer" 
  }

  rule {
    api_groups  = ["*"]
    resources   = ["*"]
    verbs       = ["*"]
  }

  depends_on = [module.eks]
}

resource "kubernetes_role_binding" "deployer" {
  for_each = toset(var.deployer_users)

  metadata {
    namespace = "default"
    name      = "deployer-role-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "deployer"
  }

  subject {
    kind      = "User"
    name      = each.key
    api_group = "rbac.authorization.k8s.io"
  }
}
