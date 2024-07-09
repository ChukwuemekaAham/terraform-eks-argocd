# locals {

#   name            = basename(path.cwd) #is the current working directory. When writing Terraform modules, we most commonly want to resolve paths relative to the module itself
#   # partition       = data.aws_partition.current.partition
#   region          = data.aws_region.current.name
#   cluster_version = "1.23"

#   vpc_cidr = "10.0.0.0/16"
#   azs      = slice(data.aws_availability_zones.available.names, 0, 3)

#   node_group_name = "managed-ondemand"

#   tags = {
#     Blueprint  = local.name
#     GithubRepo = "github.com/aws-ia/terraform-aws-eks-blueprints"
#     # GithubRepo = "github.com/chukwuemekaaham/terraform-aws-eks-blueprints"
#   }
# }


# comment out the above code to add argo application config for both repositories, eks add-on and your forked of workload repository
# The first thing we need to do, is augment our locals.tf with the two new variables addon_application and workload_application as shown below.

# Replace the entire contents of the locals.tf with the code below.

# Update the repo_url for both the workload repository with your fork replacing [ YOUR GITHUB USER HERE ].

locals {
  name            = basename(path.cwd)
  region          = data.aws_region.current.name
  cluster_version = "1.23"

  vpc_cidr      = "10.0.0.0/16"
  azs           = slice(data.aws_availability_zones.available.names, 0, 3)

  node_group_name = "managed-ondemand"

  #---------------------------------------------------------------
  # ARGOCD ADD-ON APPLICATION
  #---------------------------------------------------------------

  addon_application = {
    path               = "chart"
    repo_url           = "https://github.com/ChukwuemekaAham/eks-blueprints-add-ons.git"
    add_on_application = true
  }

  #---------------------------------------------------------------
  # ARGOCD WORKLOAD APPLICATION
  #---------------------------------------------------------------

  workload_application = {
    path               = "envs/dev"
    repo_url           = "https://github.com/ChukwuemekaAham/eks-blueprints-workloads.git"
    add_on_application = false
  }

  tags = {
   Blueprint  = local.name
     GithubRepo = "github.com/aws-ia/terraform-aws-eks-blueprints"
  }
}
