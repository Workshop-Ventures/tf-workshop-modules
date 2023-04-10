# Workshop Terraform Modules
These modules are for provisioning various components used by Workshop Ventures


# Usage
When using a module - you can refer to the github repo with a tag version to specify the exact version or github sha

```terraform
module "eks" {
  module = "git::https://github.com/Workshop-Ventures/tf-workshop-modules.git//eks/cluster?ref=v0.0.1"
}
```

