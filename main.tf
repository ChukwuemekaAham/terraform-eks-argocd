provider "kubernetes" {
  host                   = module.eks_blueprints.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_blueprints.eks_cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes {
    host                   = module.eks_blueprints.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks_blueprints.eks_cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

provider "kubectl" {
  apply_retry_count      = 10
  host                   = module.eks_blueprints.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_blueprints.eks_cluster_certificate_authority_data)
  load_config_file       = false
  token                  = data.aws_eks_cluster_auth.this.token
}

module "eks_blueprints" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints?ref=v4.12.2"

  cluster_name    = local.name

  # EKS Cluster VPC and Subnet mandatory config
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnets

  # EKS CONTROL PLANE VARIABLES
  cluster_version = local.cluster_version

  # List of Additional roles admin in the cluster
  # Comment this section if you ARE NOTE at an AWS Event, as the TeamRole won't exist on your site, 
  # or replace with any valid role you want
  map_roles = [
    {
      rolearn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/myTeamRole"
      username = "ahamadmin" # The user name within Kubernetes to map to the IAM role
      groups   = ["system:masters"] # A list of groups within Kubernetes to which the role is mapped; Checkout K8s Role and Rolebindings
    }
  ]

  # EKS MANAGED NODE GROUPS
  managed_node_groups = {
    mg_5 = {
      node_group_name = local.node_group_name
      instance_types  = ["m5.xlarge"]
      subnet_ids      = module.vpc.private_subnets
    }
  }

  # This is the team that manages the EKS cluster provisioning.
  # This will create a dedicated role arn:aws:iam::0123456789:role/eks-blueprint-admin-access 
  # that will allow you to managed the cluster as administrator.
  # It also define which existing users/roles will be allowed to assume 
  # this role via the users parameter where you can provide a list of  
  # IAM arns. The new role is also configured in the EKS Configmap to 
  # allow authentication.
  platform_teams = {
    admin = {
      users = [
        data.aws_caller_identity.current.arn,
        # data.aws_iam_role.team_event.arn
      ]
    }
  }

  # define a Development Team in the EKS Platform as a Tenant.
  # This will create a dedicated 
  # role arn:aws:iam::0123456789:role/eks-blueprint-team-marble-access 
  # that will allow you to managed the Team Marble authentication in EKS. 
  # The created IAM role will also be configured in the EKS Configmap.
  # The Team Marble being created is in fact a Kubernetes namespace with 
  # associated kubernetes RBAC and quotas, in this case team-marble. 
  # You can adjust the labels and quotas to values appropriate to the 
  # team you are adding. EKS

  # We are also using the manifest_dir directory that allow you to install 
  # specific kubernetes manifests at the namespace creation time. 
  # You can bootstrap the namespace with dedicated network policies rules, 
  # or anything that you need.

  # Blueprint chooses to use namespaces and resource quotas to isolate application 
  # teams from each others. We can also add additional security policy 
  # enforcements and Network segreagation by applying additional kubernetes
  # manifests when creating the teams namespaces.
    application_teams = {
    team-marble = {
      "labels" = {
        "appName"     = "marble-team-app",
        "projectName" = "project-marble",
        "environment" = "dev",
        "domain"      = "example",
        "uuid"        = "example",
        "billingCode" = "example",
        "branch"      = "example"
      }
      "quota" = {
        "requests.cpu"    = "10000m",
        "requests.memory" = "20Gi",
        "limits.cpu"      = "20000m",
        "limits.memory"   = "50Gi",
        "pods"            = "15",
        "secrets"         = "10",
        "services"        = "10"
      }
      ## Manifests Example: we can specify a directory with kubernetes manifests that can be automatically applied in the team-marble namespace.
      manifests_dir = "./kubernetes/team-marble"
      users         = [data.aws_caller_identity.current.arn]
    }
  }


  tags = local.tags
}



module "vpc" {
  # https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.18.1"

  name = local.name
  cidr = local.vpc_cidr

  azs  = local.azs
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 10)]

  enable_nat_gateway   = true
  create_igw           = true
  enable_dns_hostnames = true
  single_nat_gateway   = true

  # Manage so we can name
  manage_default_network_acl    = true
  default_network_acl_tags      = { Name = "${local.name}-default" }
  manage_default_route_table    = true
  default_route_table_tags      = { Name = "${local.name}-default" }
  manage_default_security_group = true
  default_security_group_tags   = { Name = "${local.name}-default" }  

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.name}" = "shared"
    "kubernetes.io/role/elb"              = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.name}" = "shared"
    "kubernetes.io/role/internal-elb"     = "1"
  }

    tags = local.tags
}


# Add the kubernetes_addons module at the end of our main.tf. To indicate that ArgoCD should responsible for managing cluster add-ons, we uses the argocd_manage_add_ons property to true (see below). When this flag is set, the framework will still provision all AWS resources necessary to support add-on functionalities (IAM Roles, IAM Policies, dependant resources..), but it will not apply Helm charts directly via the Terraform Helm provider, and let Argo do it.

# We also specify a custom set to configure Argo to expose ArgoCD UI on an aws load balancer. (ideallly we should do it using an ingress but this will be easier for this lab)

# This will configure ArgoCD add-on, and allow it to deploy additional kubernetes add-ons using GitOps.

# Copy this at the end of main.tf

module "kubernetes_addons" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints?ref=v4.12.2/modules/kubernetes-addons"
  eks_cluster_id     = module.eks_blueprints.eks_cluster_id

  #---------------------------------------------------------------
  # ARGO CD ADD-ON
  #---------------------------------------------------------------

  enable_argocd         = true
  argocd_manage_add_ons = true # Indicates that ArgoCD is responsible for managing/deploying Add-ons.

  argocd_applications = {
    addons    = local.addon_application
    # Remember, in the main.tf file when we configured Argo we choosed to activate 
    # only the addon repository. update the main.tf and 
    # uncomment the workloads application when ready.
    #workloads = local.workload_application #We comment it for now
  }

  argocd_helm_config = {
    set = [
      {
        name  = "server.service.type"
        value = "LoadBalancer"
      }
    ]
  }

  # ---------------------------------------------------------------
  # ADD-ONS - You can add additional addons here
  # https://aws-ia.github.io/terraform-aws-eks-blueprints/add-ons/
  # ---------------------------------------------------------------


  enable_aws_load_balancer_controller  = true
  # enable_cert_manager                  = true
  # enable_cluster_autoscaler            = true
  enable_karpenter                     = false # for autoscaling
  enable_amazon_eks_aws_ebs_csi_driver = true
  enable_aws_for_fluentbit             = true
  enable_metrics_server                = true
  # enable_prometheus                    = true
  
  
# Deploy App Using Blue/Green StrategyHeader anchor link
# Earlier in the Bootstrap ArgoCD section, we added the kubernetes_addons module. 
# We enabled several add-ons using the EKS Blueprints for Terraform IaC. 
# Argo Rollouts comes out of the box as an add-on, so all we need to do is enable it.

#   enable_argo_rollouts                 = true # <-- Add this line

#   argo_rollouts_helm_config = {    # <-- Add this config to expose as LoadBalancer
#     set = [
#       {
#         name  = "dashboard.service.type"
#         value = "LoadBalancer"
#       }
#     ]
#   }

}


data "kubectl_path_documents" "karpenter_provisioners" {
  pattern = "${path.module}/kubernetes/karpenter/*"
  vars = {
    azs                     = join(",", local.azs)
    iam-instance-profile-id = "${local.name}-${local.node_group_name}"
    eks-cluster-id          = local.name
    eks-vpc_name            = local.name
  }
}

resource "kubectl_manifest" "karpenter_provisioner" {
  for_each  = toset(data.kubectl_path_documents.karpenter_provisioners.documents)
  yaml_body = each.value
}
