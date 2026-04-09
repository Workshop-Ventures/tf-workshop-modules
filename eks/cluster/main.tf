# EKS Cluster Module
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = var.cluster_name
  kubernetes_version = var.kubernetes_version

  endpoint_private_access = true
  endpoint_public_access  = true

  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  security_group_additional_rules = {
    ingress_nodes_ephemeral_ports_tcp = {
      description                = "Nodes on ephemeral ports"
      protocol                   = "tcp"
      from_port                  = 1025
      to_port                    = 65535
      type                       = "ingress"
      source_node_security_group = true
    }
  }

  addons = {
    # vpc-cni and kube-proxy must install BEFORE node groups, otherwise nodes
    # boot without a CNI plugin, never go Ready, and the node group create
    # fails with NodeCreationFailure: "Unhealthy nodes in the kubernetes cluster".
    vpc-cni = {
      most_recent    = true
      before_compute = true
    }
    kube-proxy = {
      most_recent    = true
      before_compute = true
    }
    coredns = {
      most_recent = true
    }
    eks-pod-identity-agent = {
      most_recent = true
    }
  }

  # The cluster creator's access is granted explicitly via system_masters below.
  # Leaving this true causes a 409 conflict when the apply-er is also in system_masters.
  enable_cluster_creator_admin_permissions = false

  # Access entries replace the removed aws-auth submodule.
  access_entries = merge(
    {
      for user in var.system_masters : "user-${user}" => {
        principal_arn = "arn:aws:iam::${var.account_id}:user/${user}"
        policy_associations = {
          admin = {
            policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
            access_scope = {
              type = "cluster"
            }
          }
        }
      }
    },
    {
      for user in var.deployer_users : "deployer-user-${user}" => {
        principal_arn = "arn:aws:iam::${var.account_id}:user/${user}"
      }
    },
    {
      for role in var.system_master_roles : "role-${role.name}" => {
        principal_arn = "arn:aws:iam::${var.account_id}:role/${role.name}"
        policy_associations = {
          admin = {
            policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
            access_scope = {
              type = "cluster"
            }
          }
        }
      }
    },
    {
      for role in var.deployer_roles : "deployer-role-${role.name}" => {
        principal_arn = "arn:aws:iam::${var.account_id}:role/${role.name}"
      }
    },
  )

  eks_managed_node_groups = {
    for group in var.node_groups :
    group.name => {
      ami_type = "AL2023_x86_64_STANDARD"
      # ami_release_version intentionally omitted — defaults to the latest AMI for the
      # cluster's kubernetes_version. Pinning here previously caused kubelet/control-plane
      # version skew and node groups failing with "Unhealthy nodes".
      name = group.name
      instance_types      = group.instance_types
      min_size            = group.min_size
      max_size            = group.max_size
      desired_size        = group.desired_size

      capacity_type = group.capacity_type

      vpc_security_group_ids = [
        aws_security_group.node_group[group.name].id
      ]
    }
  }

  tags = {
    Env       = var.env
    ManagedBy = "Terraform"
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

  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = each.value.id
  cidr_blocks       = toset(var.node_group_ssh_access)
}

# Open up the SG to itself on all ports
resource "aws_security_group_rule" "self_access" {
  for_each = aws_security_group.node_group

  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "all"
  security_group_id = each.value.id
  self              = true
}

# Deployer Role
resource "kubernetes_role_v1" "deployer" {
  metadata {
    namespace = "default"
    name      = "deployer"
  }

  rule {
    api_groups = ["*"]
    resources  = ["*"]
    verbs      = ["*"]
  }

  depends_on = [module.eks]
}

resource "kubernetes_role_binding_v1" "deployer" {
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
