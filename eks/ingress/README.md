# tf-eks-module-ingress-controller

A Terraform module for creating private/public alb and/or nginx controllers (depending on cluster environment) according to our standards.

This module has direct dependency on the EKS Cluster and Worker modules.

This module aims to install the following resouces, again dependant on environment

```
	• QA
		○ ALB Controller
		○ Private Nginx
		○ Public Nginx
		
	• STG
		○ ALB Controller

	• PRD
    ○ ALB Controller

```

To elaborate, a single ALB controller will be installed in every environment, the ALB controller is responsible for looking at proper annotations on deployed Kubernetes pods and creating Load Balancers based on the settings.  The single controller will be responsible for creating Internal as well as Internet-Facing LBs.  QA will also receive a set of NGINX controllers that will be responsible for proxying traffic to 'ephemeral' environments. 

## Inputs

| Name | Description | Type | Default | Required? |
| --- | --- | --- | --- | --- |
| account_id | AWS Account ID | String | NA | Yes |
| accont_alias | AWS Account Alias | String | NA | Yes |
| api_server_endpoint | Endpoint for your Kubernetes API server | String | NA | Yes |
| cluster_name | EKS cluster name | String | NA | Yes |
| oidc_url | OIDC Provider Url | String | NA | Yes |
| subnet_ids | List of the subnet IDs | List | NA | Yes |
| region | AWS Account Region |string | NA | Yes |

## Outputs

| Name | Description |
| --- | --- |


## Example usage

```
##################################################################
## Ingress
##################################################################

module "ingress" {
  source = "../../eks_modules/tf-eks-module-ingress-controller"

  api_server_endpoint = module.eks_cluster.eks_endpoint
  oidc_url            = module.oidc.oidc_url
  tags                = module.name-tag.default_tags
  cluster_name        = module.name-tag.service_resource_name
  subnet_ids          = data.aws_subnet_ids.private_subnets.ids
  account_id          = var.account_id
  account_alias       = var.account_alias
  region              = terraform.workspace

  depends_on = [module.eks_cluster]
}
```

### Terraform Style Guide

Follow [this](https://docs.google.com/document/d/1qZM78GKI0Z5SezuTryWz40151OrT6elPwEqR4YVB_AY/edit?ts=602d675f#) guide to make sure that your terraform code matches the styling standard used at SimpliSafe.
