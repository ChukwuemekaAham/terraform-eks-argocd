

## Deploy
After all variables are set then we are ready to go and complete deployment by provisioning all resources
such as network, load balancing, cluster, iam roles for nodes...
- VPC resources including:
  - VPC
  - Subnets
  - Internet Gateway
  - Route Table

- iam roles and policies for worker nodes and cluster to work with other AWS services.
- AWS EKS Cluster
- namespace and will do api and service deployments under this namespace.
  This helps to manage deployments separately from the others in the same cluster.
- loadbalancer service to ingress from inbound network.

Create an IAM role for your workspace
1.	Create an IAM role with Administrator access. 
2.	Confirm that AWS service and EC2 are selected, then click Next Permissions to view permissions.
3.	Confirm that AdministratorAccess is checked, then click Next: Tags to review.


Attach the IAM role to your Workspace

Check IAM settings for your Workspace

We should configure our aws cli with our current region as default.

export ACCOUNT_ID=$(aws sts get-caller-identity --output text --query Account)
export AWS_REGION=us-west-2

Check if AWS_REGION is set to desired region

test -n "$AWS_REGION" && echo AWS_REGION is "$AWS_REGION" || echo AWS_REGION is not set

Let's save these into bash_profile

echo "export ACCOUNT_ID=${ACCOUNT_ID}" | tee -a ~/.bash_profile
echo "export AWS_REGION=${AWS_REGION}" | tee -a ~/.bash_profile
aws configure set default.region ${AWS_REGION}
aws configure get default.region

Validate the IAM role

Use the GetCallerIdentity  CLI command to validate that the Cloud9 IDE is using the correct IAM role.

aws sts get-caller-identity --query Arn | grep 
eks-blueprints-for-terraform-workshop-admin -q && echo "IAM role valid" || 

echo "IAM role NOT valid"

If the IAM role is not valid, DO NOT PROCEED. Go back and confirm the steps on this page.

Provision Amazon EKS Cluster
We are ready to go get started! The next step will guide you through creating Terraform files, which we use throughout the workshop and gradually modify.

Create a Terraform Project
In this section, we will be setting up our Terraform project. Create a new folder in your file system, then add the following specific files.

1. Create a providers.tf file

Before we are able to execute any terraform CLI commands, we need to tell Terraform the versions of the providers we are using. Execute the following in your terminal.


2. Create data.tf file

In order to run any of the code we are creating, we need to have basic data variables.

3. Create outputs.tf file

We will initially output the VPC and related subnets and later we will add command to add the newly created cluster to our kubernetes ~/.kube/config configuration file which will enables access to our cluster. Please add the following contents to the output.tf


4. Create locals.tf file

For more information on Terraform Locals, take a look at the Docs .


We have setup all of our files, next we will define the VPC and Private/Public Subnets where our EKS cluster will be provisioned.


Create a VPC and Public/Private Subnets
Here we use the Terraform AWS VPC Module to provision an Amazon Virtual Private Cloud  VPC and subnets. We also make sure we enable NAT Gateway, Internet Gateway (IGW), DNS Hostnames to connect to the cluster after provisioning.
You can also see we tag the subnets as required by EKS so that Amazon Elastic Load Balancer (ELB) knows it is used for our cluster.
Use this command to create a new file called main.tf

Next, run the following terraform CLI commands to provision the AWS resources.

# initialize terraform so that we get all the required modules and providers
terraform init
View Terraform Output

# Always a good practice to use a dry-run command
terraform plan
If no errors you can proceed with deployment

# The auto approve flag avoids you having to confirm you want to provision resources.
terraform apply -auto-approve

### Output 

$ terraform apply -auto-approve
data.aws_region.current: Reading...
data.aws_availability_zones.available: Reading...
data.aws_caller_identity.current: Reading...
data.aws_region.current: Read complete after 0s [id=us-west-2]
data.aws_availability_zones.available: Read complete after 0s [id=us-west-2]
data.aws_caller_identity.current: Read complete after 1s [id=263022081217]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following  
symbols:
  + create

Terraform will perform the following actions:

  # module.vpc.aws_default_network_acl.this[0] will be created
  + resource "aws_default_network_acl" "this" {
      + arn                    = (known after apply)
      + default_network_acl_id = (known after apply)
      + id                     = (known after apply)
      + owner_id               = (known after apply)
      + tags                   = {
          + "Blueprint" = "eks-argocd-karpenter"
          + "Name"      = "eks-argocd-karpenter-default"
        }
      + tags_all               = {
          + "Blueprint" = "eks-argocd-karpenter"
          + "Name"      = "eks-argocd-karpenter-default"
        }
      + vpc_id                 = (known after apply)

      + egress {
          + action          = "allow"
          + from_port       = 0
          + ipv6_cidr_block = "::/0"
          + protocol        = "-1"
          + rule_no         = 101
          + to_port         = 0
        }
      + egress {
          + action     = "allow"
          + cidr_block = "0.0.0.0/0"
          + from_port  = 0
          + protocol   = "-1"
          + rule_no    = 100
          + to_port    = 0
        }

      + ingress {
          + action          = "allow"
          + from_port       = 0
          + ipv6_cidr_block = "::/0"
          + protocol        = "-1"
          + rule_no         = 101
          + to_port         = 0
        }
      + ingress {
          + action     = "allow"
          + cidr_block = "0.0.0.0/0"
          + from_port  = 0
          + protocol   = "-1"
          + rule_no    = 100
          + to_port    = 0
        }
    }

  # module.vpc.aws_default_route_table.default[0] will be created
  + resource "aws_default_route_table" "default" {
      + arn                    = (known after apply)
      + default_route_table_id = (known after apply)
      + id                     = (known after apply)
      + owner_id               = (known after apply)
      + route                  = (known after apply)
      + tags                   = {
          + "Blueprint" = "eks-argocd-karpenter"
          + "Name"      = "eks-argocd-karpenter-default"
        }
      + tags_all               = {
          + "Blueprint" = "eks-argocd-karpenter"
          + "Name"      = "eks-argocd-karpenter-default"
        }
      + vpc_id                 = (known after apply)

      + timeouts {
          + create = "5m"
          + update = "5m"
        }
    }

  # module.vpc.aws_default_security_group.this[0] will be created
  + resource "aws_default_security_group" "this" {
      + arn                    = (known after apply)
      + description            = (known after apply)
      + egress                 = (known after apply)
      + id                     = (known after apply)
      + ingress                = (known after apply)
      + name                   = (known after apply)
      + name_prefix            = (known after apply)
      + owner_id               = (known after apply)
      + revoke_rules_on_delete = false
      + tags                   = {
          + "Blueprint" = "eks-argocd-karpenter"
          + "Name"      = "eks-argocd-karpenter-default"
        }
      + tags_all               = {
          + "Blueprint" = "eks-argocd-karpenter"
          + "Name"      = "eks-argocd-karpenter-default"
        }
      + vpc_id                 = (known after apply)
    }

  # module.vpc.aws_eip.nat[0] will be created
  + resource "aws_eip" "nat" {
      + allocation_id        = (known after apply)
      + association_id       = (known after apply)
      + carrier_ip           = (known after apply)
      + customer_owned_ip    = (known after apply)
      + domain               = (known after apply)
      + id                   = (known after apply)
      + instance             = (known after apply)
      + network_border_group = (known after apply)
      + network_interface    = (known after apply)
      + private_dns          = (known after apply)
      + private_ip           = (known after apply)
      + public_dns           = (known after apply)
      + public_ip            = (known after apply)
      + public_ipv4_pool     = (known after apply)
      + tags                 = {
          + "Blueprint" = "eks-argocd-karpenter"
          + "Name"      = "eks-argocd-karpenter-us-west-2a"
        }
      + tags_all             = {
          + "Blueprint" = "eks-argocd-karpenter"
          + "Name"      = "eks-argocd-karpenter-us-west-2a"
        }
      + vpc                  = true
    }

  # module.vpc.aws_internet_gateway.this[0] will be created
  + resource "aws_internet_gateway" "this" {
      + arn      = (known after apply)
      + id       = (known after apply)
      + owner_id = (known after apply)
      + tags     = {
          + "Blueprint" = "eks-argocd-karpenter"
          + "Name"      = "eks-argocd-karpenter"
        }
      + tags_all = {
          + "Blueprint" = "eks-argocd-karpenter"
          + "Name"      = "eks-argocd-karpenter"
        }
      + vpc_id   = (known after apply)
    }

  # module.vpc.aws_nat_gateway.this[0] will be created
  + resource "aws_nat_gateway" "this" {
      + allocation_id        = (known after apply)
      + connectivity_type    = "public"
      + id                   = (known after apply)
      + network_interface_id = (known after apply)
      + private_ip           = (known after apply)
      + public_ip            = (known after apply)
      + subnet_id            = (known after apply)
      + tags                 = {
          + "Blueprint" = "eks-argocd-karpenter"
          + "Name"      = "eks-argocd-karpenter-us-west-2a"
        }
      + tags_all             = {
          + "Blueprint" = "eks-argocd-karpenter"
          + "Name"      = "eks-argocd-karpenter-us-west-2a"
        }
    }

  # module.vpc.aws_route.private_nat_gateway[0] will be created
  + resource "aws_route" "private_nat_gateway" {
      + destination_cidr_block = "0.0.0.0/0"
      + id                     = (known after apply)
      + instance_id            = (known after apply)
      + instance_owner_id      = (known after apply)
      + nat_gateway_id         = (known after apply)
      + network_interface_id   = (known after apply)
      + origin                 = (known after apply)
      + route_table_id         = (known after apply)
      + state                  = (known after apply)

      + timeouts {
          + create = "5m"
        }
    }

  # module.vpc.aws_route.public_internet_gateway[0] will be created
  + resource "aws_route" "public_internet_gateway" {
      + destination_cidr_block = "0.0.0.0/0"
      + gateway_id             = (known after apply)
      + id                     = (known after apply)
      + instance_id            = (known after apply)
      + instance_owner_id      = (known after apply)
      + network_interface_id   = (known after apply)
      + origin                 = (known after apply)
      + route_table_id         = (known after apply)
      + state                  = (known after apply)

      + timeouts {
          + create = "5m"
        }
    }

  # module.vpc.aws_route_table.private[0] will be created
  + resource "aws_route_table" "private" {
      + arn              = (known after apply)
      + id               = (known after apply)
      + owner_id         = (known after apply)
      + propagating_vgws = (known after apply)
      + route            = (known after apply)
      + tags             = {
          + "Blueprint" = "eks-argocd-karpenter"
          + "Name"      = "eks-argocd-karpenter-private"
        }
      + tags_all         = {
          + "Blueprint" = "eks-argocd-karpenter"
          + "Name"      = "eks-argocd-karpenter-private"
        }
      + vpc_id           = (known after apply)
    }

  # module.vpc.aws_route_table.public[0] will be created
  + resource "aws_route_table" "public" {
      + arn              = (known after apply)
      + id               = (known after apply)
      + owner_id         = (known after apply)
      + propagating_vgws = (known after apply)
      + route            = (known after apply)
      + tags             = {
          + "Blueprint" = "eks-argocd-karpenter"
          + "Name"      = "eks-argocd-karpenter-public"
        }
      + tags_all         = {
          + "Blueprint" = "eks-argocd-karpenter"
          + "Name"      = "eks-argocd-karpenter-public"
        }
      + vpc_id           = (known after apply)
    }

  # module.vpc.aws_route_table_association.private[0] will be created
  + resource "aws_route_table_association" "private" {
      + id             = (known after apply)
      + route_table_id = (known after apply)
      + subnet_id      = (known after apply)
    }

  # module.vpc.aws_route_table_association.private[1] will be created
  + resource "aws_route_table_association" "private" {
      + id             = (known after apply)
      + route_table_id = (known after apply)
      + subnet_id      = (known after apply)
    }

  # module.vpc.aws_route_table_association.private[2] will be created
  + resource "aws_route_table_association" "private" {
      + id             = (known after apply)
      + route_table_id = (known after apply)
      + subnet_id      = (known after apply)
    }

  # module.vpc.aws_route_table_association.public[0] will be created
  + resource "aws_route_table_association" "public" {
      + id             = (known after apply)
      + route_table_id = (known after apply)
      + subnet_id      = (known after apply)
    }

  # module.vpc.aws_route_table_association.public[1] will be created
  + resource "aws_route_table_association" "public" {
      + id             = (known after apply)
      + route_table_id = (known after apply)
      + subnet_id      = (known after apply)
    }

  # module.vpc.aws_route_table_association.public[2] will be created
  + resource "aws_route_table_association" "public" {
      + id             = (known after apply)
      + route_table_id = (known after apply)
      + subnet_id      = (known after apply)
    }

  # module.vpc.aws_subnet.private[0] will be created
  + resource "aws_subnet" "private" {
      + arn                                            = (known after apply)
      + assign_ipv6_address_on_creation                = false
      + availability_zone                              = "us-west-2a"
      + availability_zone_id                           = (known after apply)
      + cidr_block                                     = "10.0.10.0/24"
      + enable_dns64                                   = false
      + enable_resource_name_dns_a_record_on_launch    = false
      + enable_resource_name_dns_aaaa_record_on_launch = false
      + id                                             = (known after apply)
      + ipv6_cidr_block_association_id                 = (known after apply)
      + ipv6_native                                    = false
      + map_public_ip_on_launch                        = false
      + owner_id                                       = (known after apply)
      + private_dns_hostname_type_on_launch            = (known after apply)
      + tags                                           = {
          + "Blueprint"                                  = "eks-argocd-karpenter"
          + "Name"                                       = "eks-argocd-karpenter-private-us-west-2a"
          + "kubernetes.io/cluster/eks-argocd-karpenter" = "shared"
          + "kubernetes.io/role/internal-elb"            = "1"
        }
      + tags_all                                       = {
          + "Blueprint"                                  = "eks-argocd-karpenter"
          + "Name"                                       = "eks-argocd-karpenter-private-us-west-2a"
          + "kubernetes.io/cluster/eks-argocd-karpenter" = "shared"
          + "kubernetes.io/role/internal-elb"            = "1"
        }
      + vpc_id                                         = (known after apply)
    }

  # module.vpc.aws_subnet.private[1] will be created
  + resource "aws_subnet" "private" {
      + arn                                            = (known after apply)
      + assign_ipv6_address_on_creation                = false
      + availability_zone                              = "us-west-2b"
      + availability_zone_id                           = (known after apply)
      + cidr_block                                     = "10.0.11.0/24"
      + enable_dns64                                   = false
      + enable_resource_name_dns_a_record_on_launch    = false
      + enable_resource_name_dns_aaaa_record_on_launch = false
      + id                                             = (known after apply)
      + ipv6_cidr_block_association_id                 = (known after apply)
      + ipv6_native                                    = false
      + map_public_ip_on_launch                        = false
      + owner_id                                       = (known after apply)
      + private_dns_hostname_type_on_launch            = (known after apply)
      + tags                                           = {
          + "Blueprint"                                  = "eks-argocd-karpenter"
          + "Name"                                       = "eks-argocd-karpenter-private-us-west-2b"
          + "kubernetes.io/cluster/eks-argocd-karpenter" = "shared"
          + "kubernetes.io/role/internal-elb"            = "1"
        }
      + tags_all                                       = {
          + "Blueprint"                                  = "eks-argocd-karpenter"
          + "Name"                                       = "eks-argocd-karpenter-private-us-west-2b"
          + "kubernetes.io/cluster/eks-argocd-karpenter" = "shared"
          + "kubernetes.io/role/internal-elb"            = "1"
        }
      + vpc_id                                         = (known after apply)
    }

  # module.vpc.aws_subnet.private[2] will be created
  + resource "aws_subnet" "private" {
      + arn                                            = (known after apply)
      + assign_ipv6_address_on_creation                = false
      + availability_zone                              = "us-west-2c"
      + availability_zone_id                           = (known after apply)
      + cidr_block                                     = "10.0.12.0/24"
      + enable_dns64                                   = false
      + enable_resource_name_dns_a_record_on_launch    = false
      + enable_resource_name_dns_aaaa_record_on_launch = false
      + id                                             = (known after apply)
      + ipv6_cidr_block_association_id                 = (known after apply)
      + ipv6_native                                    = false
      + map_public_ip_on_launch                        = false
      + owner_id                                       = (known after apply)
      + private_dns_hostname_type_on_launch            = (known after apply)
      + tags                                           = {
          + "Blueprint"                                  = "eks-argocd-karpenter"
          + "Name"                                       = "eks-argocd-karpenter-private-us-west-2c"
          + "kubernetes.io/cluster/eks-argocd-karpenter" = "shared"
          + "kubernetes.io/role/internal-elb"            = "1"
        }
      + tags_all                                       = {
          + "Blueprint"                                  = "eks-argocd-karpenter"
          + "Name"                                       = "eks-argocd-karpenter-private-us-west-2c"
          + "kubernetes.io/cluster/eks-argocd-karpenter" = "shared"
          + "kubernetes.io/role/internal-elb"            = "1"
        }
      + vpc_id                                         = (known after apply)
    }

  # module.vpc.aws_subnet.public[0] will be created
  + resource "aws_subnet" "public" {
      + arn                                            = (known after apply)
      + assign_ipv6_address_on_creation                = false
      + availability_zone                              = "us-west-2a"
      + availability_zone_id                           = (known after apply)
      + cidr_block                                     = "10.0.0.0/24"
      + enable_dns64                                   = false
      + enable_resource_name_dns_a_record_on_launch    = false
      + enable_resource_name_dns_aaaa_record_on_launch = false
      + id                                             = (known after apply)
      + ipv6_cidr_block_association_id                 = (known after apply)
      + ipv6_native                                    = false
      + map_public_ip_on_launch                        = true
      + owner_id                                       = (known after apply)
      + private_dns_hostname_type_on_launch            = (known after apply)
      + tags                                           = {
          + "Blueprint"                                  = "eks-argocd-karpenter"
          + "Name"                                       = "eks-argocd-karpenter-public-us-west-2a"
          + "kubernetes.io/cluster/eks-argocd-karpenter" = "shared"
          + "kubernetes.io/role/elb"                     = "1"
        }
      + tags_all                                       = {
          + "Blueprint"                                  = "eks-argocd-karpenter"
          + "Name"                                       = "eks-argocd-karpenter-public-us-west-2a"
          + "kubernetes.io/cluster/eks-argocd-karpenter" = "shared"
          + "kubernetes.io/role/elb"                     = "1"
        }
      + vpc_id                                         = (known after apply)
    }

  # module.vpc.aws_subnet.public[1] will be created
  + resource "aws_subnet" "public" {
      + arn                                            = (known after apply)
      + assign_ipv6_address_on_creation                = false
      + availability_zone                              = "us-west-2b"
      + availability_zone_id                           = (known after apply)
      + cidr_block                                     = "10.0.1.0/24"
      + enable_dns64                                   = false
      + enable_resource_name_dns_a_record_on_launch    = false
      + enable_resource_name_dns_aaaa_record_on_launch = false
      + id                                             = (known after apply)
      + ipv6_cidr_block_association_id                 = (known after apply)
      + ipv6_native                                    = false
      + map_public_ip_on_launch                        = true
      + owner_id                                       = (known after apply)
      + private_dns_hostname_type_on_launch            = (known after apply)
      + tags                                           = {
          + "Blueprint"                                  = "eks-argocd-karpenter"
          + "Name"                                       = "eks-argocd-karpenter-public-us-west-2b"
          + "kubernetes.io/cluster/eks-argocd-karpenter" = "shared"
          + "kubernetes.io/role/elb"                     = "1"
        }
      + tags_all                                       = {
          + "Blueprint"                                  = "eks-argocd-karpenter"
          + "Name"                                       = "eks-argocd-karpenter-public-us-west-2b"
          + "kubernetes.io/cluster/eks-argocd-karpenter" = "shared"
          + "kubernetes.io/role/elb"                     = "1"
        }
      + vpc_id                                         = (known after apply)
    }

  # module.vpc.aws_subnet.public[2] will be created
  + resource "aws_subnet" "public" {
      + arn                                            = (known after apply)
      + assign_ipv6_address_on_creation                = false
      + availability_zone                              = "us-west-2c"
      + availability_zone_id                           = (known after apply)
      + cidr_block                                     = "10.0.2.0/24"
      + enable_dns64                                   = false
      + enable_resource_name_dns_a_record_on_launch    = false
      + enable_resource_name_dns_aaaa_record_on_launch = false
      + id                                             = (known after apply)
      + ipv6_cidr_block_association_id                 = (known after apply)
      + ipv6_native                                    = false
      + map_public_ip_on_launch                        = true
      + owner_id                                       = (known after apply)
      + private_dns_hostname_type_on_launch            = (known after apply)
      + tags                                           = {
          + "Blueprint"                                  = "eks-argocd-karpenter"
          + "Name"                                       = "eks-argocd-karpenter-public-us-west-2c"
          + "kubernetes.io/cluster/eks-argocd-karpenter" = "shared"
          + "kubernetes.io/role/elb"                     = "1"
        }
      + tags_all                                       = {
          + "Blueprint"                                  = "eks-argocd-karpenter"
          + "Name"                                       = "eks-argocd-karpenter-public-us-west-2c"
          + "kubernetes.io/cluster/eks-argocd-karpenter" = "shared"
          + "kubernetes.io/role/elb"                     = "1"
        }
      + vpc_id                                         = (known after apply)
    }

  # module.vpc.aws_vpc.this[0] will be created
  + resource "aws_vpc" "this" {
      + arn                                  = (known after apply)
      + cidr_block                           = "10.0.0.0/16"
      + default_network_acl_id               = (known after apply)
      + default_route_table_id               = (known after apply)
      + default_security_group_id            = (known after apply)
      + dhcp_options_id                      = (known after apply)
      + enable_classiclink                   = (known after apply)
      + enable_classiclink_dns_support       = (known after apply)
      + enable_dns_hostnames                 = true
      + enable_dns_support                   = true
      + enable_network_address_usage_metrics = (known after apply)
      + id                                   = (known after apply)
      + instance_tenancy                     = "default"
      + ipv6_association_id                  = (known after apply)
      + ipv6_cidr_block                      = (known after apply)
      + ipv6_cidr_block_network_border_group = (known after apply)
      + main_route_table_id                  = (known after apply)
      + owner_id                             = (known after apply)
      + tags                                 = {
          + "Blueprint" = "eks-argocd-karpenter"
          + "Name"      = "eks-argocd-karpenter"
        }
      + tags_all                             = {
          + "Blueprint" = "eks-argocd-karpenter"
          + "Name"      = "eks-argocd-karpenter"
        }
    }

Plan: 23 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + vpc_id = (known after apply)
module.vpc.aws_eip.nat[0]: Creating...
module.vpc.aws_vpc.this[0]: Creating...
module.vpc.aws_eip.nat[0]: Creation complete after 2s [id=eipalloc-0e4f082b188c2e853]
module.vpc.aws_vpc.this[0]: Still creating... [10s elapsed]
module.vpc.aws_vpc.this[0]: Creation complete after 17s [id=vpc-0d9620716aff3efbf]
module.vpc.aws_default_route_table.default[0]: Creating...
module.vpc.aws_route_table.public[0]: Creating...
module.vpc.aws_subnet.public[2]: Creating...
module.vpc.aws_subnet.public[0]: Creating...
module.vpc.aws_subnet.private[1]: Creating...
module.vpc.aws_default_security_group.this[0]: Creating...
module.vpc.aws_internet_gateway.this[0]: Creating...
module.vpc.aws_subnet.public[1]: Creating...
module.vpc.aws_default_network_acl.this[0]: Creating...
module.vpc.aws_route_table.private[0]: Creating...
module.vpc.aws_default_route_table.default[0]: Creation complete after 1s [id=rtb-0be071b0b0c5de428]
module.vpc.aws_subnet.private[2]: Creating...
module.vpc.aws_subnet.private[1]: Creation complete after 2s [id=subnet-0006fe7836fd7ded0]
module.vpc.aws_subnet.private[0]: Creating...
module.vpc.aws_internet_gateway.this[0]: Creation complete after 2s [id=igw-0030b4655716578a4]
module.vpc.aws_route_table.public[0]: Creation complete after 2s [id=rtb-0e1068ba108435c66]
module.vpc.aws_route.public_internet_gateway[0]: Creating...
module.vpc.aws_route_table.private[0]: Creation complete after 2s [id=rtb-01b8c2cc011b730ab]
module.vpc.aws_subnet.private[2]: Creation complete after 2s [id=subnet-037dd1cbd7e8b36c2]
module.vpc.aws_subnet.private[0]: Creation complete after 1s [id=subnet-0cf8ba85ef6966f8c]
module.vpc.aws_route_table_association.private[2]: Creating...
module.vpc.aws_route_table_association.private[0]: Creating...
module.vpc.aws_route_table_association.private[1]: Creating...
module.vpc.aws_route.public_internet_gateway[0]: Creation complete after 2s [id=r-rtb-0e1068ba108435c661080289494]
module.vpc.aws_default_security_group.this[0]: Creation complete after 4s [id=sg-079117ee2e109492d]
module.vpc.aws_default_network_acl.this[0]: Creation complete after 4s [id=acl-043d729bc983db0f1]
module.vpc.aws_route_table_association.private[1]: Creation complete after 1s [id=rtbassoc-0a779b6ee7d39e881]
module.vpc.aws_route_table_association.private[0]: Creation complete after 1s [id=rtbassoc-027a2897e180151a6]
module.vpc.aws_route_table_association.private[2]: Creation complete after 1s [id=rtbassoc-0d58d123d3a67e373]
module.vpc.aws_subnet.public[2]: Still creating... [10s elapsed]
module.vpc.aws_subnet.public[0]: Still creating... [10s elapsed]
module.vpc.aws_subnet.public[1]: Still creating... [10s elapsed]
module.vpc.aws_subnet.public[2]: Creation complete after 12s [id=subnet-09e412ce17025a5df]
module.vpc.aws_subnet.public[0]: Creation complete after 13s [id=subnet-00fb28a72ba82405b]
module.vpc.aws_subnet.public[1]: Creation complete after 13s [id=subnet-055d003096caf7864]
module.vpc.aws_route_table_association.public[0]: Creating...
module.vpc.aws_route_table_association.public[2]: Creating...
module.vpc.aws_nat_gateway.this[0]: Creating...
module.vpc.aws_route_table_association.public[1]: Creating...
module.vpc.aws_route_table_association.public[0]: Creation complete after 1s [id=rtbassoc-09101dd9bab762a7e]
module.vpc.aws_route_table_association.public[2]: Creation complete after 1s [id=rtbassoc-008ac9f6d5e6e69e1]
module.vpc.aws_route_table_association.public[1]: Creation complete after 1s [id=rtbassoc-067929e68fa67fbd5]
module.vpc.aws_nat_gateway.this[0]: Still creating... [10s elapsed]
module.vpc.aws_nat_gateway.this[0]: Still creating... [20s elapsed]
module.vpc.aws_nat_gateway.this[0]: Still creating... [30s elapsed]
module.vpc.aws_nat_gateway.this[0]: Still creating... [40s elapsed]
module.vpc.aws_nat_gateway.this[0]: Still creating... [50s elapsed]
module.vpc.aws_nat_gateway.this[0]: Still creating... [1m0s elapsed]
module.vpc.aws_nat_gateway.this[0]: Still creating... [1m10s elapsed]
module.vpc.aws_nat_gateway.this[0]: Still creating... [1m20s elapsed]
module.vpc.aws_nat_gateway.this[0]: Still creating... [1m30s elapsed]
module.vpc.aws_nat_gateway.this[0]: Still creating... [1m40s elapsed]
module.vpc.aws_nat_gateway.this[0]: Still creating... [1m50s elapsed]
module.vpc.aws_nat_gateway.this[0]: Creation complete after 1m51s [id=nat-0fb7a398b5f80b5bb]
module.vpc.aws_route.private_nat_gateway[0]: Creating...
module.vpc.aws_route.private_nat_gateway[0]: Creation complete after 2s [id=r-rtb-01b8c2cc011b730ab1080289494]

Apply complete! Resources: 23 added, 0 changed, 0 destroyed.

Outputs:

vpc_id = "vpc-0d9620716aff3efbf"
   
At this stage, we have created our VPC, you can see it in the console using this deep link 
Next, we will create the basic cluster with a managed node group.



### Provision EKS Cluster with Managed Node Group

Important
We heavily rely on Terraform modules in the workshop you can read more about them here 
Before we use the EKS Blueprints for Terraform modules , we need to add some provider-specific configuration to our main.tf
In this step, we are going to add the EKS blueprint core module and configure it, including the EKS managed node group. From the code below you can see that we are pinning the main EKS Blueprint module to v4.12.2  which corresponds to the GitHub repository release Tag. It is a good practice to lock-in all your modules to a given tried and tested version.
Please add the following (copy/paste) at the top of your main.tf right above the "vpc" module definition.

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
  # Comment this section if you ARE NOTE at an AWS Event, as the TeamRole won't exist on your site, or replace with any valid role you want
  map_roles = [
    {
      rolearn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/TeamRole"
      username = "ops-role" # The user name within Kubernetes to map to the IAM role
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

  tags = local.tags
}
Now that we have our cluster definition, we want to add a new output that will have the kubectl command for us to add a new entry to our kubeconfig in order to connect to the cluster. Please add the following to the outputs.tf

output "configure_kubectl" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = module.eks_blueprints.configure_kubectl
}
We can also declare additionals datas. Add thoses at the end of data.tf file.

data "aws_eks_cluster" "cluster" {
  name = module.eks_blueprints.eks_cluster_id
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks_blueprints.eks_cluster_id
}
Important
Don't forget to save the cloud9 files as auto-save is not enabled by default.
Next, execute the following commands in your terminal so that we can add the EKS Blueprints Terraform Module.

# we need to do this again, since we added a new module.
terraform init

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.

# Always a good practice to use a dry-run command
terraform plan

# then provision our EKS cluster
# the auto approve flag avoids you having to confirm you want to provision resources.
terraform apply -auto-approve



View Terraform Output
 # module.eks_blueprints.module.aws_eks.data.tls_certificate.this[0] will be read during apply
  # (config refers to values not yet known)
 <= data "tls_certificate" "this" {
      + certificates = (known after apply)
      + id           = (known after apply)
      + url          = (known after apply)
    }

  # module.eks_blueprints.module.aws_eks.aws_ec2_tag.cluster_primary_security_group["Blueprint"] will be created
  + resource "aws_ec2_tag" "cluster_primary_security_group" {
      + id          = (known after apply)
      + key         = "Blueprint"
      + resource_id = (known after apply)
      + value       = "eks-argocd-karpenter"
    }

  # module.eks_blueprints.module.aws_eks.aws_ec2_tag.cluster_primary_security_group["GithubRepo"] will be created
  + resource "aws_ec2_tag" "cluster_primary_security_group" {
      + id          = (known after apply)
      + key         = "GithubRepo"
      + resource_id = (known after apply)
      + value       = "github.com/aws-ia/terraform-aws-eks-blueprints"
    }

  # module.eks_blueprints.module.aws_eks.aws_eks_cluster.this[0] will be created
  + resource "aws_eks_cluster" "this" {
      + arn                       = (known after apply)
      + certificate_authority     = (known after apply)
      + created_at                = (known after apply)
      + enabled_cluster_log_types = [
          + "api",
          + "audit",
          + "authenticator",
          + "controllerManager",
          + "scheduler",
        ]
      + endpoint                  = (known after apply)
      + id                        = (known after apply)
      + identity                  = (known after apply)
      + name                      = "eks-argocd-karpenter"
      + platform_version          = (known after apply)
      + role_arn                  = (known after apply)
      + status                    = (known after apply)
      + tags                      = {
          + "Blueprint"  = "eks-argocd-karpenter"
          + "GithubRepo" = "github.com/aws-ia/terraform-aws-eks-blueprints"
        }
      + tags_all                  = {
          + "Blueprint"  = "eks-argocd-karpenter"
          + "GithubRepo" = "github.com/aws-ia/terraform-aws-eks-blueprints"
        }
      + version                   = "1.23"

      + encryption_config {
          + resources = [
              + "secrets",
            ]

          + provider {
              + key_arn = (known after apply)
            }
        }

      + kubernetes_network_config {
          + ip_family         = "ipv4"
          + service_ipv4_cidr = (known after apply)
          + service_ipv6_cidr = (known after apply)
        }

      + timeouts {}

      + vpc_config {
          + cluster_security_group_id = (known after apply)
          + endpoint_private_access   = false
          + endpoint_public_access    = true
          + public_access_cidrs       = [
              + "0.0.0.0/0",
            ]
          + security_group_ids        = (known after apply)
          + subnet_ids                = [
              + "subnet-0006fe7836fd7ded0",
              + "subnet-037dd1cbd7e8b36c2",
              + "subnet-0cf8ba85ef6966f8c",
            ]
          + vpc_id                    = (known after apply)
        }
    }

  # module.eks_blueprints.module.aws_eks.aws_iam_openid_connect_provider.oidc_provider[0] will be created
  + resource "aws_iam_openid_connect_provider" "oidc_provider" {
      + arn             = (known after apply)
      + client_id_list  = [
          + "sts.amazonaws.com",
        ]
      + id              = (known after apply)
      + tags            = {
          + "Blueprint"  = "eks-argocd-karpenter"
          + "GithubRepo" = "github.com/aws-ia/terraform-aws-eks-blueprints"
          + "Name"       = "eks-argocd-karpenter-eks-irsa"
        }
      + tags_all        = {
          + "Blueprint"  = "eks-argocd-karpenter"
          + "GithubRepo" = "github.com/aws-ia/terraform-aws-eks-blueprints"
          + "Name"       = "eks-argocd-karpenter-eks-irsa"
        }
      + thumbprint_list = (known after apply)
      + url             = (known after apply)
    }

  # module.eks_blueprints.module.aws_eks.aws_iam_role.this[0] will be created
  + resource "aws_iam_role" "this" {
      + arn                   = (known after apply)
      + assume_role_policy    = jsonencode(
            {
              + Statement = [
                  + {
                      + Action    = "sts:AssumeRole"
                      + Effect    = "Allow"
                      + Principal = {
                          + Service = "eks.amazonaws.com"
                        }
                      + Sid       = "EKSClusterAssumeRole"
                    },
                ]
              + Version   = "2012-10-17"
            }
        )
      + create_date           = (known after apply)
      + force_detach_policies = true
      + id                    = (known after apply)
      + managed_policy_arns   = (known after apply)
      + max_session_duration  = 3600
      + name                  = "eks-argocd-karpenter-cluster-role"
      + name_prefix           = (known after apply)
      + path                  = "/"
      + tags                  = {
          + "Blueprint"  = "eks-argocd-karpenter"
          + "GithubRepo" = "github.com/aws-ia/terraform-aws-eks-blueprints"
        }
      + tags_all              = {
          + "Blueprint"  = "eks-argocd-karpenter"
          + "GithubRepo" = "github.com/aws-ia/terraform-aws-eks-blueprints"
        }
      + unique_id             = (known after apply)

      + inline_policy {
          + name   = (known after apply)
          + policy = (known after apply)
        }
    }

  # module.eks_blueprints.module.aws_eks.aws_iam_role_policy_attachment.this["arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"] will be created
  + resource "aws_iam_role_policy_attachment" "this" {
      + id         = (known after apply)
      + policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
      + role       = "eks-argocd-karpenter-cluster-role"
    }

  # module.eks_blueprints.module.aws_eks.aws_iam_role_policy_attachment.this["arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"] will be created
  + resource "aws_iam_role_policy_attachment" "this" {
      + id         = (known after apply)
      + policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
      + role       = "eks-argocd-karpenter-cluster-role"
    }

  # module.eks_blueprints.module.aws_eks.aws_security_group.cluster[0] will be created
  + resource "aws_security_group" "cluster" {
      + arn                    = (known after apply)
      + description            = "EKS cluster security group"
      + egress                 = (known after apply)
      + id                     = (known after apply)
      + ingress                = (known after apply)
      + name                   = (known after apply)
      + name_prefix            = "eks-argocd-karpenter-cluster-"
      + owner_id               = (known after apply)
      + revoke_rules_on_delete = false
      + tags                   = {
          + "Blueprint"  = "eks-argocd-karpenter"
          + "GithubRepo" = "github.com/aws-ia/terraform-aws-eks-blueprints"
          + "Name"       = "eks-argocd-karpenter-cluster"
        }
      + tags_all               = {
          + "Blueprint"  = "eks-argocd-karpenter"
          + "GithubRepo" = "github.com/aws-ia/terraform-aws-eks-blueprints"
          + "Name"       = "eks-argocd-karpenter-cluster"
        }
      + vpc_id                 = "vpc-0d9620716aff3efbf"
    }

  # module.eks_blueprints.module.aws_eks.aws_security_group.node[0] will be created
  + resource "aws_security_group" "node" {
      + arn                    = (known after apply)
      + description            = "EKS node shared security group"
      + egress                 = (known after apply)
      + id                     = (known after apply)
      + ingress                = (known after apply)
      + name                   = (known after apply)
      + name_prefix            = "eks-argocd-karpenter-node-"
      + owner_id               = (known after apply)
      + revoke_rules_on_delete = false
      + tags                   = {
          + "Blueprint"                                  = "eks-argocd-karpenter"
          + "GithubRepo"                                 = "github.com/aws-ia/terraform-aws-eks-blueprints"
          + "Name"                                       = "eks-argocd-karpenter-node"
          + "kubernetes.io/cluster/eks-argocd-karpenter" = "owned"
        }
      + tags_all               = {
          + "Blueprint"                                  = "eks-argocd-karpenter"
          + "GithubRepo"                                 = "github.com/aws-ia/terraform-aws-eks-blueprints"
          + "Name"                                       = "eks-argocd-karpenter-node"
          + "kubernetes.io/cluster/eks-argocd-karpenter" = "owned"
        }
      + vpc_id                 = "vpc-0d9620716aff3efbf"
    }

  # module.eks_blueprints.module.aws_eks.aws_security_group_rule.cluster["egress_nodes_443"] will be created
  + resource "aws_security_group_rule" "cluster" {
      + description              = "Cluster API to node groups"
      + from_port                = 443
      + id                       = (known after apply)
      + prefix_list_ids          = []
      + protocol                 = "tcp"
      + security_group_id        = (known after apply)
      + security_group_rule_id   = (known after apply)
      + self                     = false
      + source_security_group_id = (known after apply)
      + to_port                  = 443
      + type                     = "egress"
    }

  # module.eks_blueprints.module.aws_eks.aws_security_group_rule.cluster["egress_nodes_kubelet"] will be created
  + resource "aws_security_group_rule" "cluster" {
      + description              = "Cluster API to node kubelets"
      + from_port                = 10250
      + id                       = (known after apply)
      + prefix_list_ids          = []
      + protocol                 = "tcp"
      + security_group_id        = (known after apply)
      + security_group_rule_id   = (known after apply)
      + self                     = false
      + source_security_group_id = (known after apply)
      + to_port                  = 10250
      + type                     = "egress"
    }

  # module.eks_blueprints.module.aws_eks.aws_security_group_rule.cluster["ingress_nodes_443"] will be created
  + resource "aws_security_group_rule" "cluster" {
      + description              = "Node groups to cluster API"
      + from_port                = 443
      + id                       = (known after apply)
      + prefix_list_ids          = []
      + protocol                 = "tcp"
      + security_group_id        = (known after apply)
      + security_group_rule_id   = (known after apply)
      + self                     = false
      + source_security_group_id = (known after apply)
      + to_port                  = 443
      + type                     = "ingress"
    }

  # module.eks_blueprints.module.aws_eks.aws_security_group_rule.node["egress_cluster_443"] will be created
  + resource "aws_security_group_rule" "node" {
      + description              = "Node groups to cluster API"
      + from_port                = 443
      + id                       = (known after apply)
      + prefix_list_ids          = []
      + protocol                 = "tcp"
      + security_group_id        = (known after apply)
      + security_group_rule_id   = (known after apply)
      + self                     = false
      + source_security_group_id = (known after apply)
      + to_port                  = 443
      + type                     = "egress"
    }

  # module.eks_blueprints.module.aws_eks.aws_security_group_rule.node["egress_https"] will be created
  + resource "aws_security_group_rule" "node" {
      + cidr_blocks              = [
          + "0.0.0.0/0",
        ]
      + description              = "Egress all HTTPS to internet"
      + from_port                = 443
      + id                       = (known after apply)
      + prefix_list_ids          = []
      + protocol                 = "tcp"
      + security_group_id        = (known after apply)
      + security_group_rule_id   = (known after apply)
      + self                     = false
      + source_security_group_id = (known after apply)
      + to_port                  = 443
      + type                     = "egress"
    }

  # module.eks_blueprints.module.aws_eks.aws_security_group_rule.node["egress_ntp_tcp"] will be created
  + resource "aws_security_group_rule" "node" {
      + cidr_blocks              = [
          + "0.0.0.0/0",
        ]
      + description              = "Egress NTP/TCP to internet"
      + from_port                = 123
      + id                       = (known after apply)
      + prefix_list_ids          = []
      + protocol                 = "tcp"
      + security_group_id        = (known after apply)
      + security_group_rule_id   = (known after apply)
      + self                     = false
      + source_security_group_id = (known after apply)
      + to_port                  = 123
      + type                     = "egress"
    }

  # module.eks_blueprints.module.aws_eks.aws_security_group_rule.node["egress_ntp_udp"] will be created
  + resource "aws_security_group_rule" "node" {
      + cidr_blocks              = [
          + "0.0.0.0/0",
        ]
      + description              = "Egress NTP/UDP to internet"
      + from_port                = 123
      + id                       = (known after apply)
      + prefix_list_ids          = []
      + protocol                 = "udp"
      + security_group_id        = (known after apply)
      + security_group_rule_id   = (known after apply)
      + self                     = false
      + source_security_group_id = (known after apply)
      + to_port                  = 123
      + type                     = "egress"
    }

  # module.eks_blueprints.module.aws_eks.aws_security_group_rule.node["egress_self_coredns_tcp"] will be created
  + resource "aws_security_group_rule" "node" {
      + description              = "Node to node CoreDNS"
      + from_port                = 53
      + id                       = (known after apply)
      + prefix_list_ids          = []
      + protocol                 = "tcp"
      + security_group_id        = (known after apply)
      + security_group_rule_id   = (known after apply)
      + self                     = true
      + source_security_group_id = (known after apply)
      + to_port                  = 53
      + type                     = "egress"
    }

  # module.eks_blueprints.module.aws_eks.aws_security_group_rule.node["egress_self_coredns_udp"] will be created
  + resource "aws_security_group_rule" "node" {
      + description              = "Node to node CoreDNS"
      + from_port                = 53
      + id                       = (known after apply)
      + prefix_list_ids          = []
      + protocol                 = "udp"
      + security_group_id        = (known after apply)
      + security_group_rule_id   = (known after apply)
      + self                     = true
      + source_security_group_id = (known after apply)
      + to_port                  = 53
      + type                     = "egress"
    }

  # module.eks_blueprints.module.aws_eks.aws_security_group_rule.node["ingress_cluster_443"] will be created
  + resource "aws_security_group_rule" "node" {
      + description              = "Cluster API to node groups"
      + from_port                = 443
      + id                       = (known after apply)
      + prefix_list_ids          = []
      + protocol                 = "tcp"
      + security_group_id        = (known after apply)
      + security_group_rule_id   = (known after apply)
      + self                     = false
      + source_security_group_id = (known after apply)
      + to_port                  = 443
      + type                     = "ingress"
    }

  # module.eks_blueprints.module.aws_eks.aws_security_group_rule.node["ingress_cluster_kubelet"] will be created
  + resource "aws_security_group_rule" "node" {
      + description              = "Cluster API to node kubelets"
      + from_port                = 10250
      + id                       = (known after apply)
      + prefix_list_ids          = []
      + protocol                 = "tcp"
      + security_group_id        = (known after apply)
      + security_group_rule_id   = (known after apply)
      + self                     = false
      + source_security_group_id = (known after apply)
      + to_port                  = 10250
      + type                     = "ingress"
    }

  # module.eks_blueprints.module.aws_eks.aws_security_group_rule.node["ingress_self_coredns_tcp"] will be created
  + resource "aws_security_group_rule" "node" {
      + description              = "Node to node CoreDNS"
      + from_port                = 53
      + id                       = (known after apply)
      + prefix_list_ids          = []
      + protocol                 = "tcp"
      + security_group_id        = (known after apply)
      + security_group_rule_id   = (known after apply)
      + self                     = true
      + source_security_group_id = (known after apply)
      + to_port                  = 53
      + type                     = "ingress"
    }

  # module.eks_blueprints.module.aws_eks.aws_security_group_rule.node["ingress_self_coredns_udp"] will be created
  + resource "aws_security_group_rule" "node" {
      + description              = "Node to node CoreDNS"
      + from_port                = 53
      + id                       = (known after apply)
      + prefix_list_ids          = []
      + protocol                 = "udp"
      + security_group_id        = (known after apply)
      + security_group_rule_id   = (known after apply)
      + self                     = true
      + source_security_group_id = (known after apply)
      + to_port                  = 53
      + type                     = "ingress"
    }

  # module.eks_blueprints.module.aws_eks_managed_node_groups["mg_5"].data.aws_iam_policy_document.managed_ng_assume_role_policy will be read during apply
  # (depends on a resource or a module with changes pending)
 <= data "aws_iam_policy_document" "managed_ng_assume_role_policy" {
      + id   = (known after apply)
      + json = (known after apply)

      + statement {
          + actions = [
              + "sts:AssumeRole",
            ]
          + sid     = "EKSWorkerAssumeRole"

          + principals {
              + identifiers = [
                  + "ec2.amazonaws.com",
                ]
              + type        = "Service"
            }
        }
    }

  # module.eks_blueprints.module.aws_eks_managed_node_groups["mg_5"].aws_eks_node_group.managed_ng will be created
  + resource "aws_eks_node_group" "managed_ng" {
      + ami_type               = "AL2_x86_64"
      + arn                    = (known after apply)
      + capacity_type          = "ON_DEMAND"
      + cluster_name           = (known after apply)
      + disk_size              = 50
      + id                     = (known after apply)
      + instance_types         = [
          + "m5.xlarge",
        ]
      + node_group_name        = (known after apply)
      + node_group_name_prefix = "managed-ondemand-"
      + node_role_arn          = (known after apply)
      + release_version        = (known after apply)
      + resources              = (known after apply)
      + status                 = (known after apply)
      + subnet_ids             = [
          + "subnet-0006fe7836fd7ded0",
          + "subnet-037dd1cbd7e8b36c2",
          + "subnet-0cf8ba85ef6966f8c",
        ]
      + tags                   = (known after apply)
      + tags_all               = (known after apply)
      + version                = "1.23"

      + scaling_config {
          + desired_size = 3
          + max_size     = 3
          + min_size     = 1
        }

      + timeouts {
          + create = "30m"
          + delete = "30m"
          + update = "2h"
        }

      + update_config {
          + max_unavailable = 1
        }
    }

  # module.eks_blueprints.module.aws_eks_managed_node_groups["mg_5"].aws_iam_instance_profile.managed_ng[0] will be created
  + resource "aws_iam_instance_profile" "managed_ng" {
      + arn         = (known after apply)
      + create_date = (known after apply)
      + id          = (known after apply)
      + name        = (known after apply)
      + path        = "/"
      + role        = (known after apply)
      + tags        = {
          + "Blueprint"  = "eks-argocd-karpenter"
          + "GithubRepo" = "github.com/aws-ia/terraform-aws-eks-blueprints"
        }
      + tags_all    = {
          + "Blueprint"  = "eks-argocd-karpenter"
          + "GithubRepo" = "github.com/aws-ia/terraform-aws-eks-blueprints"
        }
      + unique_id   = (known after apply)
    }

  # module.eks_blueprints.module.aws_eks_managed_node_groups["mg_5"].aws_iam_role.managed_ng[0] will be created
  + resource "aws_iam_role" "managed_ng" {
      + arn                   = (known after apply)
      + assume_role_policy    = (known after apply)
      + create_date           = (known after apply)
      + description           = "EKS Managed Node group IAM Role"
      + force_detach_policies = true
      + id                    = (known after apply)
      + managed_policy_arns   = (known after apply)
      + max_session_duration  = 3600
      + name                  = (known after apply)
      + name_prefix           = (known after apply)
      + path                  = "/"
      + tags                  = {
          + "Blueprint"  = "eks-argocd-karpenter"
          + "GithubRepo" = "github.com/aws-ia/terraform-aws-eks-blueprints"
        }
      + tags_all              = {
          + "Blueprint"  = "eks-argocd-karpenter"
          + "GithubRepo" = "github.com/aws-ia/terraform-aws-eks-blueprints"
        }
      + unique_id             = (known after apply)

      + inline_policy {
          + name   = (known after apply)
          + policy = (known after apply)
        }
    }

  # module.eks_blueprints.module.aws_eks_managed_node_groups["mg_5"].aws_iam_role_policy_attachment.managed_ng["arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"] will be created
  + resource "aws_iam_role_policy_attachment" "managed_ng" {
      + id         = (known after apply)
      + policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
      + role       = (known after apply)
    }

  # module.eks_blueprints.module.aws_eks_managed_node_groups["mg_5"].aws_iam_role_policy_attachment.managed_ng["arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"] will be created
  + resource "aws_iam_role_policy_attachment" "managed_ng" {
      + id         = (known after apply)
      + policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
      + role       = (known after apply)
    }

  # module.eks_blueprints.module.aws_eks_managed_node_groups["mg_5"].aws_iam_role_policy_attachment.managed_ng["arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"] will be created
  + resource "aws_iam_role_policy_attachment" "managed_ng" {
      + id         = (known after apply)
      + policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
      + role       = (known after apply)
    }

  # module.eks_blueprints.module.aws_eks_managed_node_groups["mg_5"].aws_iam_role_policy_attachment.managed_ng["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"] will be created
  + resource "aws_iam_role_policy_attachment" "managed_ng" {
      + id         = (known after apply)
      + policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
      + role       = (known after apply)
    }

  # module.eks_blueprints.module.kms[0].aws_kms_alias.this will be created
  + resource "aws_kms_alias" "this" {
      + arn            = (known after apply)
      + id             = (known after apply)
      + name           = "alias/eks-argocd-karpenter"
      + name_prefix    = (known after apply)
      + target_key_arn = (known after apply)
      + target_key_id  = (known after apply)
    }

  # module.eks_blueprints.module.kms[0].aws_kms_key.this will be created
  + resource "aws_kms_key" "this" {
      + arn                                = (known after apply)
      + bypass_policy_lockout_safety_check = false
      + customer_master_key_spec           = "SYMMETRIC_DEFAULT"
      + deletion_window_in_days            = 30
      + description                        = "eks-argocd-karpenter EKS cluster secret encryption key"
      + enable_key_rotation                = true
      + id                                 = (known after apply)
      + is_enabled                         = true
      + key_id                             = (known after apply)
      + key_usage                          = "ENCRYPT_DECRYPT"
      + multi_region                       = (known after apply)
      + policy                             = jsonencode(
            {
              + Statement = [
                  + {
                      + Action    = [
                          + "kms:ReEncrypt*",
                          + "kms:GenerateDataKey*",
                          + "kms:Encrypt",
                          + "kms:DescribeKey",
                          + "kms:Decrypt",
                          + "kms:CreateGrant",
                        ]
                      + Condition = {
                          + StringEquals = {
                              + "kms:CallerAccount" = "263022081217"
                              + "kms:ViaService"    = "eks.us-west-2.amazonaws.com"
                            }
                        }
                      + Effect    = "Allow"
                      + Principal = {
                          + AWS = "arn:aws:iam::263022081217:root"
                        }
                      + Resource  = "*"
                      + Sid       = "Allow access for all principals in the account that are authorized"
                    },
                  + {
                      + Action    = [
                          + "kms:RevokeGrant",
                          + "kms:List*",
                          + "kms:Get*",
                          + "kms:Describe*",
                        ]
                      + Effect    = "Allow"
                      + Principal = {
                          + AWS = "arn:aws:iam::263022081217:root"
                        }
                      + Resource  = "*"
                      + Sid       = "Allow direct access to key metadata to the account"
                    },
                  + {
                      + Action    = "kms:*"
                      + Effect    = "Allow"
                      + Principal = {
                          + AWS = "arn:aws:iam::263022081217:user/ahamadmin"
                        }
                      + Resource  = "*"
                      + Sid       = "Allow access for Key Administrators"
                    },
                  + {
                      + Action    = [
                          + "kms:ReEncrypt*",
                          + "kms:GenerateDataKey*",
                          + "kms:Encrypt",
                          + "kms:DescribeKey",
                          + "kms:Decrypt",
                        ]
                      + Effect    = "Allow"
                      + Principal = {
                          + AWS = "arn:aws:iam::263022081217:role/eks-argocd-karpenter-cluster-role"
                        }
                      + Resource  = "*"
                      + Sid       = "Allow use of the key"
                    },
                  + {
                      + Action    = [
                          + "kms:RevokeGrant",
                          + "kms:ListGrants",
                          + "kms:CreateGrant",
                        ]
                      + Condition = {
                          + Bool = {
                              + "kms:GrantIsForAWSResource" = "true"
                            }
                        }
                      + Effect    = "Allow"
                      + Principal = {
                          + AWS = "arn:aws:iam::263022081217:role/eks-argocd-karpenter-cluster-role"
                        }
                      + Resource  = "*"
                      + Sid       = "Allow attachment of persistent resources"
                    },
                ]
              + Version   = "2012-10-17"
            }
        )
      + tags                               = {
          + "Blueprint"  = "eks-argocd-karpenter"
          + "GithubRepo" = "github.com/aws-ia/terraform-aws-eks-blueprints"
        }
      + tags_all                           = {
          + "Blueprint"  = "eks-argocd-karpenter"
          + "GithubRepo" = "github.com/aws-ia/terraform-aws-eks-blueprints"
        }
    }

Plan: 32 to add, 15 to change, 0 to destroy.

Changes to Outputs:
  + configure_kubectl = (known after apply)
module.eks_blueprints.module.kms[0].aws_kms_key.this: Creating...
module.eks_blueprints.module.aws_eks.aws_iam_role.this[0]: Creating...
module.vpc.aws_eip.nat[0]: Modifying... [id=eipalloc-0e4f082b188c2e853]
module.vpc.aws_vpc.this[0]: Modifying... [id=vpc-0d9620716aff3efbf]
module.vpc.aws_eip.nat[0]: Modifications complete after 2s [id=eipalloc-0e4f082b188c2e853]
module.eks_blueprints.module.aws_eks.aws_iam_role.this[0]: Creation complete after 3s [id=eks-argocd-karpenter-cluster-role]
module.eks_blueprints.module.aws_eks.aws_iam_role_policy_attachment.this["arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"]: Creating...
module.eks_blueprints.module.aws_eks.aws_iam_role_policy_attachment.this["arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"]: Creating...
module.eks_blueprints.module.aws_eks.aws_iam_role_policy_attachment.this["arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"]: Creation complete after 0s [id=eks-argocd-karpenter-cluster-role-20221206225804876500000001]
module.eks_blueprints.module.aws_eks.aws_iam_role_policy_attachment.this["arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"]: Creation complete after 0s [id=eks-argocd-karpenter-cluster-role-20221206225805125500000002]
module.vpc.aws_vpc.this[0]: Modifications complete after 4s [id=vpc-0d9620716aff3efbf]
module.vpc.aws_subnet.private[1]: Modifying... [id=subnet-0006fe7836fd7ded0]
module.vpc.aws_subnet.public[1]: Modifying... [id=subnet-055d003096caf7864]
module.vpc.aws_subnet.private[2]: Modifying... [id=subnet-037dd1cbd7e8b36c2]
module.vpc.aws_default_security_group.this[0]: Modifying... [id=sg-079117ee2e109492d]
module.vpc.aws_internet_gateway.this[0]: Modifying... [id=igw-0030b4655716578a4]
module.vpc.aws_route_table.private[0]: Modifying... [id=rtb-01b8c2cc011b730ab]
module.vpc.aws_subnet.public[2]: Modifying... [id=subnet-09e412ce17025a5df]
module.vpc.aws_default_route_table.default[0]: Modifying... [id=rtb-0be071b0b0c5de428]
module.vpc.aws_default_network_acl.this[0]: Modifying... [id=acl-043d729bc983db0f1]
module.vpc.aws_internet_gateway.this[0]: Modifications complete after 2s [id=igw-0030b4655716578a4]
module.vpc.aws_subnet.private[0]: Modifying... [id=subnet-0cf8ba85ef6966f8c]
module.vpc.aws_subnet.private[2]: Modifications complete after 2s [id=subnet-037dd1cbd7e8b36c2]
module.vpc.aws_subnet.public[0]: Modifying... [id=subnet-00fb28a72ba82405b]
module.vpc.aws_subnet.private[1]: Modifications complete after 2s [id=subnet-0006fe7836fd7ded0]
module.vpc.aws_route_table.public[0]: Modifying... [id=rtb-0e1068ba108435c66]
module.vpc.aws_subnet.public[1]: Modifications complete after 2s [id=subnet-055d003096caf7864]
module.vpc.aws_route_table.private[0]: Modifications complete after 2s [id=rtb-01b8c2cc011b730ab]
module.eks_blueprints.module.aws_eks.aws_security_group.node[0]: Creating...
module.eks_blueprints.module.aws_eks.aws_security_group.cluster[0]: Creating...
module.vpc.aws_subnet.public[2]: Modifications complete after 2s [id=subnet-09e412ce17025a5df]
module.vpc.aws_default_route_table.default[0]: Modifications complete after 2s [id=rtb-0be071b0b0c5de428]
module.vpc.aws_default_network_acl.this[0]: Modifications complete after 2s [id=acl-043d729bc983db0f1]
module.vpc.aws_default_security_group.this[0]: Modifications complete after 2s [id=sg-079117ee2e109492d]
module.vpc.aws_route_table.public[0]: Modifications complete after 0s [id=rtb-0e1068ba108435c66]
module.vpc.aws_subnet.public[0]: Modifications complete after 1s [id=subnet-00fb28a72ba82405b]
module.vpc.aws_subnet.private[0]: Modifications complete after 1s [id=subnet-0cf8ba85ef6966f8c]
module.vpc.aws_nat_gateway.this[0]: Modifying... [id=nat-0fb7a398b5f80b5bb]
module.vpc.aws_nat_gateway.this[0]: Modifications complete after 0s [id=nat-0fb7a398b5f80b5bb]
module.eks_blueprints.module.aws_eks.aws_security_group.node[0]: Creation complete after 3s [id=sg-0047b45728a041c50]
module.eks_blueprints.module.aws_eks.aws_security_group.cluster[0]: Creation complete after 3s [id=sg-017b92c4932936982]
module.eks_blueprints.module.aws_eks.aws_security_group_rule.node["ingress_cluster_kubelet"]: Creating...
module.eks_blueprints.module.aws_eks.aws_security_group_rule.node["ingress_self_coredns_tcp"]: Creating...
module.eks_blueprints.module.aws_eks.aws_security_group_rule.node["ingress_cluster_443"]: Creating...
module.eks_blueprints.module.aws_eks.aws_security_group_rule.cluster["egress_nodes_443"]: Creating...
module.eks_blueprints.module.aws_eks.aws_security_group_rule.node["egress_ntp_udp"]: Creating...
module.eks_blueprints.module.aws_eks.aws_security_group_rule.cluster["egress_nodes_kubelet"]: Creating...
module.eks_blueprints.module.aws_eks.aws_security_group_rule.node["egress_cluster_443"]: Creating...
module.eks_blueprints.module.aws_eks.aws_security_group_rule.cluster["ingress_nodes_443"]: Creating...
module.eks_blueprints.module.aws_eks.aws_security_group_rule.node["egress_self_coredns_tcp"]: Creating...
module.eks_blueprints.module.kms[0].aws_kms_key.this: Still creating... [10s elapsed]
module.eks_blueprints.module.aws_eks.aws_security_group_rule.cluster["egress_nodes_443"]: Creation complete after 2s [id=sgrule-1760040862]
module.eks_blueprints.module.aws_eks.aws_security_group_rule.node["ingress_cluster_kubelet"]: Creation complete after 2s [id=sgrule-28297278]
module.eks_blueprints.module.aws_eks.aws_security_group_rule.node["egress_https"]: Creating...
module.eks_blueprints.module.aws_eks.aws_security_group_rule.node["ingress_self_coredns_udp"]: Creating...
module.eks_blueprints.module.aws_eks.aws_security_group_rule.cluster["egress_nodes_kubelet"]: Creation complete after 3s [id=sgrule-498419367]
module.eks_blueprints.module.aws_eks.aws_security_group_rule.node["ingress_self_coredns_tcp"]: Creation complete after 3s [id=sgrule-4008599412]
module.eks_blueprints.module.aws_eks.aws_security_group_rule.node["egress_self_coredns_udp"]: Creating...
module.eks_blueprints.module.aws_eks.aws_security_group_rule.node["egress_ntp_tcp"]: Creating...
module.eks_blueprints.module.aws_eks.aws_security_group_rule.cluster["ingress_nodes_443"]: Creation complete after 4s [id=sgrule-654832680]
module.eks_blueprints.module.aws_eks.aws_security_group_rule.node["ingress_cluster_443"]: Creation complete after 5s [id=sgrule-3473567713]
module.eks_blueprints.module.aws_eks.aws_security_group_rule.node["egress_ntp_udp"]: Creation complete after 6s [id=sgrule-440103849]
module.eks_blueprints.module.aws_eks.aws_security_group_rule.node["egress_cluster_443"]: Creation complete after 7s [id=sgrule-3849477127]
module.eks_blueprints.module.aws_eks.aws_security_group_rule.node["egress_self_coredns_tcp"]: Creation complete after 8s [id=sgrule-2372128237]
module.eks_blueprints.module.aws_eks.aws_security_group_rule.node["egress_https"]: Creation complete after 8s [id=sgrule-3145427898]
module.eks_blueprints.module.aws_eks.aws_security_group_rule.node["ingress_self_coredns_udp"]: Creation complete after 9s [id=sgrule-1253178523]
module.eks_blueprints.module.kms[0].aws_kms_key.this: Still creating... [20s elapsed]
module.eks_blueprints.module.aws_eks.aws_security_group_rule.node["egress_self_coredns_udp"]: Creation complete after 10s [id=sgrule-50614155]
module.eks_blueprints.module.aws_eks.aws_security_group_rule.node["egress_ntp_tcp"]: Still creating... [10s elapsed]
module.eks_blueprints.module.aws_eks.aws_security_group_rule.node["egress_ntp_tcp"]: Creation complete after 11s [id=sgrule-1688557220]
module.eks_blueprints.module.kms[0].aws_kms_key.this: Still creating... [30s elapsed]
module.eks_blueprints.module.kms[0].aws_kms_key.this: Creation complete after 38s [id=0568c3fb-c7ba-4c9b-a0bf-838806bfbb5f]
module.eks_blueprints.module.kms[0].aws_kms_alias.this: Creating...
module.eks_blueprints.module.aws_eks.aws_eks_cluster.this[0]: Creating...
module.eks_blueprints.module.kms[0].aws_kms_alias.this: Creation complete after 1s [id=alias/eks-argocd-karpenter]
module.eks_blueprints.module.aws_eks.aws_eks_cluster.this[0]: Still creating... [10s elapsed]
module.eks_blueprints.module.aws_eks.aws_eks_cluster.this[0]: Still creating... [20s elapsed]
module.eks_blueprints.module.aws_eks.aws_eks_cluster.this[0]: Still creating... [30s elapsed]
module.eks_blueprints.module.aws_eks.aws_eks_cluster.this[0]: Still creating... [40s elapsed]
module.eks_blueprints.module.aws_eks.aws_eks_cluster.this[0]: Still creating... [51s elapsed]
module.eks_blueprints.module.aws_eks.aws_eks_cluster.this[0]: Still creating... [1m1s elapsed]
module.eks_blueprints.module.aws_eks.aws_eks_cluster.this[0]: Still creating... [1m11s elapsed]
module.eks_blueprints.module.aws_eks.aws_eks_cluster.this[0]: Still creating... [1m21s elapsed]
module.eks_blueprints.module.aws_eks.aws_eks_cluster.this[0]: Still creating... [1m31s elapsed]
module.eks_blueprints.module.aws_eks.aws_eks_cluster.this[0]: Still creating... [1m41s elapsed]
module.eks_blueprints.module.aws_eks.aws_eks_cluster.this[0]: Still creating... [1m51s elapsed]
module.eks_blueprints.module.aws_eks.aws_eks_cluster.this[0]: Still creating... [2m1s elapsed]
module.eks_blueprints.module.aws_eks.aws_eks_cluster.this[0]: Still creating... [2m11s elapsed]
module.eks_blueprints.module.aws_eks.aws_eks_cluster.this[0]: Still creating... [2m21s elapsed]
module.eks_blueprints.module.aws_eks.aws_eks_cluster.this[0]: Still creating... [2m31s elapsed]
module.eks_blueprints.module.aws_eks.aws_eks_cluster.this[0]: Still creating... [2m41s elapsed]
module.eks_blueprints.module.aws_eks.aws_eks_cluster.this[0]: Still creating... [2m51s elapsed]
module.eks_blueprints.module.aws_eks.aws_eks_cluster.this[0]: Still creating... [3m1s elapsed]
module.eks_blueprints.module.aws_eks.aws_eks_cluster.this[0]: Still creating... [3m11s elapsed]
module.eks_blueprints.module.aws_eks.aws_eks_cluster.this[0]: Still creating... [3m21s elapsed]
module.eks_blueprints.module.aws_eks.aws_eks_cluster.this[0]: Still creating... [3m31s elapsed]
module.eks_blueprints.module.aws_eks.aws_eks_cluster.this[0]: Still creating... [3m41s elapsed]
module.eks_blueprints.module.aws_eks.aws_eks_cluster.this[0]: Still creating... [3m51s elapsed]
module.eks_blueprints.module.aws_eks.aws_eks_cluster.this[0]: Still creating... [4m1s elapsed]
module.eks_blueprints.module.aws_eks.aws_eks_cluster.this[0]: Still creating... [4m11s elapsed]
module.eks_blueprints.module.aws_eks.aws_eks_cluster.this[0]: Still creating... [4m21s elapsed]
module.eks_blueprints.module.aws_eks.aws_eks_cluster.this[0]: Still creating... [4m31s elapsed]
module.eks_blueprints.module.aws_eks.aws_eks_cluster.this[0]: Still creating... [4m41s elapsed]
module.eks_blueprints.module.aws_eks.aws_eks_cluster.this[0]: Still creating... [4m51s elapsed]
module.eks_blueprints.module.aws_eks.aws_eks_cluster.this[0]: Still creating... [5m1s elapsed]
module.eks_blueprints.module.aws_eks.aws_eks_cluster.this[0]: Still creating... [5m11s elapsed]
module.eks_blueprints.module.aws_eks.aws_eks_cluster.this[0]: Still creating... [5m21s elapsed]
module.eks_blueprints.module.aws_eks.aws_eks_cluster.this[0]: Still creating... [5m31s elapsed]
module.eks_blueprints.module.aws_eks.aws_eks_cluster.this[0]: Still creating... [5m41s elapsed]
module.eks_blueprints.module.aws_eks.aws_eks_cluster.this[0]: Still creating... [5m51s elapsed]
module.eks_blueprints.module.aws_eks.aws_eks_cluster.this[0]: Still creating... [6m1s elapsed]
module.eks_blueprints.module.aws_eks.aws_eks_cluster.this[0]: Still creating... [6m11s elapsed]
module.eks_blueprints.module.aws_eks.aws_eks_cluster.this[0]: Still creating... [6m21s elapsed]
module.eks_blueprints.module.aws_eks.aws_eks_cluster.this[0]: Still creating... [6m31s elapsed]
module.eks_blueprints.module.aws_eks.aws_eks_cluster.this[0]: Still creating... [6m41s elapsed]
module.eks_blueprints.module.aws_eks.aws_eks_cluster.this[0]: Still creating... [6m51s elapsed]
module.eks_blueprints.module.aws_eks.aws_eks_cluster.this[0]: Still creating... [7m1s elapsed]
module.eks_blueprints.module.aws_eks.aws_eks_cluster.this[0]: Still creating... [7m11s elapsed]
module.eks_blueprints.module.aws_eks.aws_eks_cluster.this[0]: Still creating... [7m21s elapsed]
module.eks_blueprints.module.aws_eks.aws_eks_cluster.this[0]: Still creating... [7m31s elapsed]
module.eks_blueprints.module.aws_eks.aws_eks_cluster.this[0]: Still creating... [7m41s elapsed]
module.eks_blueprints.module.aws_eks.aws_eks_cluster.this[0]: Still creating... [7m51s elapsed]
module.eks_blueprints.module.aws_eks.aws_eks_cluster.this[0]: Still creating... [8m1s elapsed]
module.eks_blueprints.module.aws_eks.aws_eks_cluster.this[0]: Still creating... [8m11s elapsed]
module.eks_blueprints.module.aws_eks.aws_eks_cluster.this[0]: Still creating... [8m21s elapsed]
module.eks_blueprints.module.aws_eks.aws_eks_cluster.this[0]: Creation complete after 8m29s [id=eks-argocd-karpenter]
module.eks_blueprints.data.aws_eks_cluster.cluster[0]: Reading...
module.eks_blueprints.module.aws_eks.aws_ec2_tag.cluster_primary_security_group["Blueprint"]: Creating...
data.aws_eks_cluster.cluster: Reading...
data.aws_eks_cluster_auth.this: Reading...
module.eks_blueprints.module.aws_eks.aws_ec2_tag.cluster_primary_security_group["GithubRepo"]: Creating...
data.aws_eks_cluster_auth.this: Read complete after 0s [id=eks-argocd-karpenter]
module.eks_blueprints.module.aws_eks.data.tls_certificate.this[0]: Reading...
module.eks_blueprints.data.aws_eks_cluster.cluster[0]: Read complete after 1s [id=eks-argocd-karpenter]
data.aws_eks_cluster.cluster: Read complete after 1s [id=eks-argocd-karpenter]
module.eks_blueprints.module.aws_eks.data.tls_certificate.this[0]: Read complete after 1s [id=64f4090f1ce5e41f5adb6ee379e80f74c3f0d039]
module.eks_blueprints.module.aws_eks.aws_ec2_tag.cluster_primary_security_group["Blueprint"]: Creation complete after 4s [id=sg-02d3b96eab541da89,Blueprint]
module.eks_blueprints.module.aws_eks.aws_ec2_tag.cluster_primary_security_group["GithubRepo"]: Creation complete after 4s [id=sg-02d3b96eab541da89,GithubRepo]
module.eks_blueprints.data.http.eks_cluster_readiness[0]: Reading...
module.eks_blueprints.module.aws_eks.aws_iam_openid_connect_provider.oidc_provider[0]: Creating...
module.eks_blueprints.module.aws_eks.aws_iam_openid_connect_provider.oidc_provider[0]: Creation complete after 1s [id=arn:aws:iam::263022081217:oidc-provider/oidc.eks.us-west-2.amazonaws.com/id/49B392510EA3E9E1AE8E67FE9FC8134C]
module.eks_blueprints.data.http.eks_cluster_readiness[0]: Read complete after 2s [id=https://49B392510EA3E9E1AE8E67FE9FC8134C.gr7.us-west-2.eks.amazonaws.com/healthz]
module.eks_blueprints.kubernetes_config_map.aws_auth[0]: Creating...
module.eks_blueprints.kubernetes_config_map.aws_auth[0]: Creation complete after 2s [id=kube-system/aws-auth]
module.eks_blueprints.module.aws_eks_managed_node_groups["mg_5"].data.aws_iam_policy_document.managed_ng_assume_role_policy: Reading...
module.eks_blueprints.module.aws_eks_managed_node_groups["mg_5"].data.aws_iam_policy_document.managed_ng_assume_role_policy: Read complete after 0s [id=3778018924]
module.eks_blueprints.module.aws_eks_managed_node_groups["mg_5"].aws_iam_role.managed_ng[0]: Creating...
module.eks_blueprints.module.aws_eks_managed_node_groups["mg_5"].aws_iam_role.managed_ng[0]: Creation complete after 1s [id=eks-argocd-karpenter-managed-ondemand]
module.eks_blueprints.module.aws_eks_managed_node_groups["mg_5"].aws_iam_role_policy_attachment.managed_ng["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]: Creating...
module.eks_blueprints.module.aws_eks_managed_node_groups["mg_5"].aws_iam_role_policy_attachment.managed_ng["arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"]: Creating...
module.eks_blueprints.module.aws_eks_managed_node_groups["mg_5"].aws_iam_role_policy_attachment.managed_ng["arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"]: Creating...
module.eks_blueprints.module.aws_eks_managed_node_groups["mg_5"].aws_iam_role_policy_attachment.managed_ng["arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"]: Creating...
module.eks_blueprints.module.aws_eks_managed_node_groups["mg_5"].aws_iam_instance_profile.managed_ng[0]: Creating...
module.eks_blueprints.module.aws_eks_managed_node_groups["mg_5"].aws_iam_role_policy_attachment.managed_ng["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]: Creation complete after 1s [id=eks-argocd-karpenter-managed-ondemand-20221206230718435400000005]  
module.eks_blueprints.module.aws_eks_managed_node_groups["mg_5"].aws_iam_role_policy_attachment.managed_ng["arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"]: Creation complete after 1s [id=eks-argocd-karpenter-managed-ondemand-20221206230718684200000006]
module.eks_blueprints.module.aws_eks_managed_node_groups["mg_5"].aws_iam_role_policy_attachment.managed_ng["arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"]: Creation complete after 1s [id=eks-argocd-karpenter-managed-ondemand-20221206230718933200000007]     
module.eks_blueprints.module.aws_eks_managed_node_groups["mg_5"].aws_iam_role_policy_attachment.managed_ng["arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"]: Creation complete after 1s [id=eks-argocd-karpenter-managed-ondemand-20221206230719049200000008]
module.eks_blueprints.module.aws_eks_managed_node_groups["mg_5"].aws_iam_instance_profile.managed_ng[0]: Creation complete after 2s [id=eks-argocd-karpenter-managed-ondemand]
module.eks_blueprints.module.aws_eks_managed_node_groups["mg_5"].aws_eks_node_group.managed_ng: Creating...
module.eks_blueprints.module.aws_eks_managed_node_groups["mg_5"].aws_eks_node_group.managed_ng: Still creating... [10s elapsed]    
module.eks_blueprints.module.aws_eks_managed_node_groups["mg_5"].aws_eks_node_group.managed_ng: Still creating... [20s elapsed]    
module.eks_blueprints.module.aws_eks_managed_node_groups["mg_5"].aws_eks_node_group.managed_ng: Still creating... [30s elapsed]    
module.eks_blueprints.module.aws_eks_managed_node_groups["mg_5"].aws_eks_node_group.managed_ng: Still creating... [40s elapsed]    
module.eks_blueprints.module.aws_eks_managed_node_groups["mg_5"].aws_eks_node_group.managed_ng: Still creating... [50s elapsed]    
module.eks_blueprints.module.aws_eks_managed_node_groups["mg_5"].aws_eks_node_group.managed_ng: Still creating... [1m0s elapsed]   
ks-argocd-karpenter:managed-ondemand-20221206230719837600000009]

Apply complete! Resources: 32 added, 15 changed, 0 destroyed.

Outputs:

configure_kubectl = "aws eks --region us-west-2 update-kubeconfig --name eks-argocd-karpenter"
vpc_id = "vpc-0d9620716aff3efbf"


### Add Platform and Application Teams

Add Platform Team

Platform Team
Acting as the Platform Team, we will use the EKS Blueprints for Terraform  which is a solution entirely written in Terraform HCL language. It helps you build a shared platform where multiple teams can consume and deploy their workloads. The EKS underlying technology is Kubernetes of course, so having some experience with Terraform and Kubernetes is helpful. You will be guided by our AWS experts (on-site) as you follow along on this workshop.

The first thing we need to do, is add the Platform Team definition to our main.tf in the module eks_blueprints. This is the team that manages the EKS cluster provisioning.

# Add the flagged code in the eks_blueprints module

Copy the platform team definition
  platform_teams = {
    admin = {
      users = [
        data.aws_caller_identity.current.arn
      ]
    }
  }
And paste it in the eks_blueprints module at the end of the # EKS MANAGED NODE GROUPS part in main.tf.

This will create a dedicated role arn:aws:iam::[ACCOUNT_ID]:role/eks-blueprint-admin-access that will allow you to managed the cluster as administrator.

It also define which existing users/roles will be allowed to assume this role via the users parameter where you can provide a list of IAM arns. The new role is also configured in the EKS Configmap to allow authentication.



Application Team
Once the EKS Cluster has been provisioned, a Application Team (Riker Team) will deploy a workload. The workload is a basic static web app. The static site will be deployed using GitOps continuous delivery.

Our next step is to define a Development Team in the EKS Platform as a Tenant. To do that, we add the following section to the main.tf
Under the platform team definition we add the following. If you have specific IAM Roles you would like to add to the team definition, you can do so in the users array which expects the IAM Role ARN.
Quotas are also enabled as shown below. Deploying resources without CPU or Memory limits will fail.
Add code below after the platform_teams we just added in eks_blueprints module
  application_teams = {
    team-riker = {
      "labels" = {
        "appName"     = "riker-team-app",
        "projectName" = "project-riker",
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
      ## Manifests Example: we can specify a directory with kubernetes manifests that can be automatically applied in the team-riker namespace.
      manifests_dir = "./kubernetes/team-riker"
      users         = [data.aws_caller_identity.current.arn]
    }
  }
This will create a dedicated role arn:aws:iam::0123456789:role/eks-blueprint-team-riker-access that will allow you to managed the Team Riker authentication in EKS. The created IAM role will also be configured in the EKS Configmap.
The Team Riker being created is in fact a Kubernetes namespace with associated kubernetes RBAC and quotas, in this case team-riker. You can adjust the labels and quotas to values appropriate to the team you are adding. EKS
We are also using the manifest_dir directory that allow you to install specific kubernetes manifests at the namespace creation time. You can bootstrap the namespace with dedicated network policies rules, or anything that you need.
Blueprint chooses to use namespaces and resource quotas to isolate application teams from each others. We can also add additional security policy enforcements and Network segreagation by applying additional kubernetes manifests when creating the teams namespaces.
We are going to create a default limit range that will inject default resources/limits to our pods if they where not defined

mkdir -p kubernetes/team-riker
cat << EOF > kubernetes/team-riker/limit-range.yaml
apiVersion: 'v1'
kind: 'LimitRange'
metadata:
  name: 'resource-limits'
  namespace: team-marble
spec:
  limits:
    - type: 'Container'
      max:
        cpu: '2'
        memory: '1Gi'
      min:
        cpu: '50m'
        memory: '4Mi'
      default:
        cpu: '300m'
        memory: '200Mi'
      defaultRequest:
        cpu: '200m'
        memory: '100Mi'
      maxLimitRequestRatio:
        cpu: '10'

EOF
Important
Don't forget to save the cloud9 file as auto-save is not enabled by default.
Now using the Terraform CLI, update the resources in AWS using the cli, note the -auto-approve flag that skips user approval to deploy changes without having to type “yes” as a confirmation to provision resources.

# Always a good practice to use a dry-run command
terraform plan

# apply changes to provision the Platform Team
terraform apply -auto-approve

$ terraform apply -auto-approve
module.eks_blueprints.module.aws_eks.module.kms.data.aws_partition.current: Reading...
module.eks_blueprints.data.aws_partition.current: Reading...
data.aws_availability_zones.available: Reading...
data.aws_region.current: Reading...
module.vpc.aws_vpc.this[0]: Refreshing state... [id=vpc-0d9620716aff3efbf]
module.eks_blueprints.module.aws_eks.module.kms.data.aws_partition.current: Read complete after 0s [id=aws]
module.eks_blueprints.data.aws_partition.current: Read complete after 0s [id=aws]
module.eks_blueprints.module.aws_eks.data.aws_caller_identity.current: Reading...
module.eks_blueprints.data.aws_region.current: Reading...
module.eks_blueprints.data.aws_caller_identity.current: Reading...
data.aws_caller_identity.current: Reading...
module.eks_blueprints.module.aws_eks.data.aws_partition.current: Reading...
module.eks_blueprints.data.aws_region.current: Read complete after 0s [id=us-west-2]
module.eks_blueprints.module.aws_eks.module.kms.data.aws_caller_identity.current: Reading...
module.eks_blueprints.module.aws_eks.data.aws_partition.current: Read complete after 0s [id=aws]
module.eks_blueprints.module.aws_eks.data.aws_iam_policy_document.assume_role_policy[0]: Reading...
data.aws_region.current: Read complete after 0s [id=us-west-2]
module.eks_blueprints.module.aws_eks.data.aws_iam_policy_document.assume_role_policy[0]: Read complete after 0s [id=2764486067]    
module.eks_blueprints.module.aws_eks.aws_iam_role.this[0]: Refreshing state... [id=eks-argocd-karpenter-cluster-role]
data.aws_availability_zones.available: Read complete after 1s [id=us-west-2]
module.vpc.aws_eip.nat[0]: Refreshing state... [id=eipalloc-0e4f082b188c2e853]
module.eks_blueprints.data.aws_caller_identity.current: Read complete after 1s [id=263022081217]
module.eks_blueprints.module.aws_eks.module.kms.data.aws_caller_identity.current: Read complete after 1s [id=263022081217]
module.eks_blueprints.module.aws_eks.data.aws_caller_identity.current: Read complete after 1s [id=263022081217]
module.eks_blueprints.data.aws_iam_session_context.current: Reading...
module.eks_blueprints.data.aws_iam_session_context.current: Read complete after 0s [id=arn:aws:iam::263022081217:user/ahamadmin]   
module.eks_blueprints.data.aws_iam_policy_document.eks_key: Reading...
module.eks_blueprints.data.aws_iam_policy_document.eks_key: Read complete after 0s [id=4211920452]
module.eks_blueprints.module.kms[0].aws_kms_key.this: Refreshing state... [id=0568c3fb-c7ba-4c9b-a0bf-838806bfbb5f]
data.aws_caller_identity.current: Read complete after 1s [id=263022081217]
module.eks_blueprints.module.aws_eks_teams[0].data.aws_partition.current: Reading...
module.eks_blueprints.module.aws_eks_teams[0].data.aws_region.current: Reading...
module.eks_blueprints.module.aws_eks_teams[0].data.aws_caller_identity.current: Reading...
module.eks_blueprints.module.aws_eks_teams[0].data.aws_partition.current: Read complete after 0s [id=aws]
module.eks_blueprints.module.aws_eks_teams[0].data.aws_region.current: Read complete after 0s [id=us-west-2]
module.eks_blueprints.module.aws_eks_teams[0].data.aws_caller_identity.current: Read complete after 1s [id=263022081217]
module.eks_blueprints.module.aws_eks.aws_iam_role_policy_attachment.this["arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"]: Refreshing state... [id=eks-argocd-karpenter-cluster-role-20221206225804876500000001]
module.eks_blueprints.module.aws_eks.aws_iam_role_policy_attachment.this["arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"]: Refreshing state... [id=eks-argocd-karpenter-cluster-role-20221206225805125500000002]
module.eks_blueprints.module.kms[0].aws_kms_alias.this: Refreshing state... [id=alias/eks-argocd-karpenter]
module.vpc.aws_default_route_table.default[0]: Refreshing state... [id=rtb-0be071b0b0c5de428]
module.vpc.aws_default_security_group.this[0]: Refreshing state... [id=sg-079117ee2e109492d]
module.vpc.aws_default_network_acl.this[0]: Refreshing state... [id=acl-043d729bc983db0f1]
module.eks_blueprints.module.aws_eks.aws_security_group.node[0]: Refreshing state... [id=sg-0047b45728a041c50]
module.eks_blueprints.module.aws_eks.aws_security_group.cluster[0]: Refreshing state... [id=sg-017b92c4932936982]
module.vpc.aws_subnet.private[2]: Refreshing state... [id=subnet-037dd1cbd7e8b36c2]
module.vpc.aws_internet_gateway.this[0]: Refreshing state... [id=igw-0030b4655716578a4]
module.vpc.aws_route_table.private[0]: Refreshing state... [id=rtb-01b8c2cc011b730ab]
module.vpc.aws_route_table.public[0]: Refreshing state... [id=rtb-0e1068ba108435c66]
module.vpc.aws_subnet.private[0]: Refreshing state... [id=subnet-0cf8ba85ef6966f8c]
module.vpc.aws_subnet.private[1]: Refreshing state... [id=subnet-0006fe7836fd7ded0]
module.vpc.aws_subnet.public[0]: Refreshing state... [id=subnet-00fb28a72ba82405b]
module.vpc.aws_subnet.public[1]: Refreshing state... [id=subnet-055d003096caf7864]
module.vpc.aws_subnet.public[2]: Refreshing state... [id=subnet-09e412ce17025a5df]
module.eks_blueprints.module.aws_eks.aws_security_group_rule.cluster["egress_nodes_443"]: Refreshing state... [id=sgrule-1760040862]
module.eks_blueprints.module.aws_eks.aws_security_group_rule.cluster["egress_nodes_kubelet"]: Refreshing state... [id=sgrule-498419367]
module.eks_blueprints.module.aws_eks.aws_security_group_rule.cluster["ingress_nodes_443"]: Refreshing state... [id=sgrule-654832680]
module.eks_blueprints.module.aws_eks.aws_security_group_rule.node["egress_ntp_udp"]: Refreshing state... [id=sgrule-440103849]
module.eks_blueprints.module.aws_eks.aws_security_group_rule.node["ingress_self_coredns_udp"]: Refreshing state... [id=sgrule-1253178523]
module.eks_blueprints.module.aws_eks.aws_security_group_rule.node["ingress_cluster_kubelet"]: Refreshing state... [id=sgrule-28297278]
module.eks_blueprints.module.aws_eks.aws_security_group_rule.node["ingress_self_coredns_tcp"]: Refreshing state... [id=sgrule-4008599412]
module.eks_blueprints.module.aws_eks.aws_security_group_rule.node["egress_ntp_tcp"]: Refreshing state... [id=sgrule-1688557220]
module.eks_blueprints.module.aws_eks.aws_security_group_rule.node["egress_cluster_443"]: Refreshing state... [id=sgrule-3849477127]
module.eks_blueprints.module.aws_eks.aws_security_group_rule.node["egress_self_coredns_tcp"]: Refreshing state... [id=sgrule-2372128237]
module.eks_blueprints.module.aws_eks.aws_security_group_rule.node["egress_self_coredns_udp"]: Refreshing state... [id=sgrule-50614155]
module.eks_blueprints.module.aws_eks.aws_security_group_rule.node["egress_https"]: Refreshing state... [id=sgrule-3145427898]
module.eks_blueprints.module.aws_eks.aws_security_group_rule.node["ingress_cluster_443"]: Refreshing state... [id=sgrule-3473567713]
module.vpc.aws_route.public_internet_gateway[0]: Refreshing state... [id=r-rtb-0e1068ba108435c661080289494]
module.vpc.aws_route_table_association.private[0]: Refreshing state... [id=rtbassoc-027a2897e180151a6]
module.vpc.aws_route_table_association.private[1]: Refreshing state... [id=rtbassoc-0a779b6ee7d39e881]
module.vpc.aws_route_table_association.private[2]: Refreshing state... [id=rtbassoc-0d58d123d3a67e373]
module.vpc.aws_route_table_association.public[0]: Refreshing state... [id=rtbassoc-09101dd9bab762a7e]
module.vpc.aws_route_table_association.public[1]: Refreshing state... [id=rtbassoc-067929e68fa67fbd5]
module.vpc.aws_route_table_association.public[2]: Refreshing state... [id=rtbassoc-008ac9f6d5e6e69e1]
module.vpc.aws_nat_gateway.this[0]: Refreshing state... [id=nat-0fb7a398b5f80b5bb]
module.eks_blueprints.module.aws_eks.aws_eks_cluster.this[0]: Refreshing state... [id=eks-argocd-karpenter]
module.vpc.aws_route.private_nat_gateway[0]: Refreshing state... [id=r-rtb-01b8c2cc011b730ab1080289494]
module.eks_blueprints.module.aws_eks.data.tls_certificate.this[0]: Reading...
module.eks_blueprints.module.aws_eks.aws_ec2_tag.cluster_primary_security_group["Blueprint"]: Refreshing state... [id=sg-02d3b96eab541da89,Blueprint]
module.eks_blueprints.module.aws_eks.aws_ec2_tag.cluster_primary_security_group["GithubRepo"]: Refreshing state... [id=sg-02d3b96eab541da89,GithubRepo]
module.eks_blueprints.data.aws_eks_cluster.cluster[0]: Reading...
data.aws_eks_cluster_auth.this: Reading...
module.eks_blueprints.module.aws_eks_teams[0].data.aws_eks_cluster.eks_cluster: Reading...
data.aws_eks_cluster.cluster: Reading...
data.aws_eks_cluster_auth.this: Read complete after 0s [id=eks-argocd-karpenter]
module.eks_blueprints.module.aws_eks_teams[0].data.aws_eks_cluster.eks_cluster: Read complete after 1s [id=eks-argocd-karpenter]
data.aws_eks_cluster.cluster: Read complete after 1s [id=eks-argocd-karpenter]
module.eks_blueprints.data.aws_eks_cluster.cluster[0]: Read complete after 1s [id=eks-argocd-karpenter]
module.eks_blueprints.module.aws_eks.data.tls_certificate.this[0]: Read complete after 2s [id=64f4090f1ce5e41f5adb6ee379e80f74c3f0d039]
module.eks_blueprints.data.http.eks_cluster_readiness[0]: Reading...
module.eks_blueprints.module.aws_eks.aws_iam_openid_connect_provider.oidc_provider[0]: Refreshing state... [id=arn:aws:iam::263022081217:oidc-provider/oidc.eks.us-west-2.amazonaws.com/id/49B392510EA3E9E1AE8E67FE9FC8134C]
module.eks_blueprints.module.aws_eks_teams[0].data.aws_iam_policy_document.platform_team_eks_access[0]: Reading...
module.eks_blueprints.module.aws_eks_teams[0].data.aws_iam_policy_document.platform_team_eks_access[0]: Read complete after 0s [id=3535608626]
module.eks_blueprints.data.http.eks_cluster_readiness[0]: Read complete after 1s [id=https://49B392510EA3E9E1AE8E67FE9FC8134C.gr7.us-west-2.eks.amazonaws.com/healthz]
module.eks_blueprints.kubernetes_config_map.aws_auth[0]: Refreshing state... [id=kube-system/aws-auth]
module.eks_blueprints.module.aws_eks_managed_node_groups["mg_5"].aws_iam_role.managed_ng[0]: Refreshing state... [id=eks-argocd-karpenter-managed-ondemand]
module.eks_blueprints.module.aws_eks_managed_node_groups["mg_5"].aws_iam_instance_profile.managed_ng[0]: Refreshing state... [id=eks-argocd-karpenter-managed-ondemand]
module.eks_blueprints.module.aws_eks_managed_node_groups["mg_5"].aws_iam_role_policy_attachment.managed_ng["arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"]: Refreshing state... [id=eks-argocd-karpenter-managed-ondemand-20221206230718684200000006]   
module.eks_blueprints.module.aws_eks_managed_node_groups["mg_5"].aws_iam_role_policy_attachment.managed_ng["arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"]: Refreshing state... [id=eks-argocd-karpenter-managed-ondemand-20221206230718933200000007]
module.eks_blueprints.module.aws_eks_managed_node_groups["mg_5"].aws_iam_role_policy_attachment.managed_ng["arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"]: Refreshing state... [id=eks-argocd-karpenter-managed-ondemand-20221206230719049200000008]
module.eks_blueprints.module.aws_eks_managed_node_groups["mg_5"].aws_iam_role_policy_attachment.managed_ng["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]: Refreshing state... [id=eks-argocd-karpenter-managed-ondemand-20221206230718435400000005]
module.eks_blueprints.module.aws_eks_managed_node_groups["mg_5"].aws_eks_node_group.managed_ng: Refreshing state... [id=eks-argocd-karpenter:managed-ondemand-20221206230719837600000009]

Note: Objects have changed outside of Terraform

Terraform detected the following changes made outside of Terraform since the last "terraform apply" which may have affected this
plan:

  # module.eks_blueprints.module.aws_eks_managed_node_groups["mg_5"].aws_eks_node_group.managed_ng has changed
  ~ resource "aws_eks_node_group" "managed_ng" {
        id                     = "eks-argocd-karpenter:managed-ondemand-20221206230719837600000009"
      + labels                 = {}
        tags                   = {
            "Blueprint"                                      = "eks-argocd-karpenter"
            "GithubRepo"                                     = "github.com/aws-ia/terraform-aws-eks-blueprints"
            "Name"                                           = "eks-argocd-karpenter-managed-ondemand"
            "k8s.io/cluster-autoscaler/eks-argocd-karpenter" = "owned"
            "k8s.io/cluster-autoscaler/enabled"              = "TRUE"
            "kubernetes.io/cluster/eks-argocd-karpenter"     = "owned"
            "managed-by"                                     = "terraform-aws-eks-blueprints"
        }
        # (15 unchanged attributes hidden)

        # (3 unchanged blocks hidden)
    }

  # module.eks_blueprints.module.aws_eks_managed_node_groups["mg_5"].aws_iam_role.managed_ng[0] has changed
  ~ resource "aws_iam_role" "managed_ng" {
        id                    = "eks-argocd-karpenter-managed-ondemand"
      ~ managed_policy_arns   = [
          + "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
          + "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
          + "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
          + "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
        ]
        name                  = "eks-argocd-karpenter-managed-ondemand"
        tags                  = {
            "Blueprint"  = "eks-argocd-karpenter"
            "GithubRepo" = "github.com/aws-ia/terraform-aws-eks-blueprints"
        }
        # (9 unchanged attributes hidden)
    }


Unless you have made equivalent changes to your configuration, or ignored the relevant attributes using ignore_changes, the        
following plan may include actions to undo or respond to these changes.

────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── 

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following  
symbols:
  + create
  ~ update in-place
 <= read (data resources)

Terraform will perform the following actions:

  # module.eks_blueprints.kubernetes_config_map.aws_auth[0] will be updated in-place
  ~ resource "kubernetes_config_map" "aws_auth" {
      ~ data        = {
          ~ "mapRoles"    = <<-EOT
                - "groups":
                  - "system:bootstrappers"
                  - "system:nodes"
                  "rolearn": "arn:aws:iam::263022081217:role/eks-argocd-karpenter-managed-ondemand"
                  "username": "system:node:{{EC2PrivateDNSName}}"
                - "groups":
              +   - "team-marble-group"
              +   "rolearn": "arn:aws:iam::263022081217:role/eks-argocd-karpenter-team-marble-access"
              +   "username": "team-marble"
              + - "groups":
                  - "system:masters"
              +   "rolearn": "arn:aws:iam::263022081217:role/eks-argocd-karpenter-admin-access"
              +   "username": "admin"
              + - "groups":
              +   - "system:masters"
                  "rolearn": "arn:aws:iam::263022081217:role/myTeamRole"
                  "username": "ahamadmin"
            EOT
            # (2 unchanged elements hidden)
        }
        id          = "kube-system/aws-auth"
        # (2 unchanged attributes hidden)

        # (1 unchanged block hidden)
    }

  # module.eks_blueprints.module.aws_eks_managed_node_groups["mg_5"].data.aws_iam_policy_document.managed_ng_assume_role_policy will be read during apply
  # (depends on a resource or a module with changes pending)
 <= data "aws_iam_policy_document" "managed_ng_assume_role_policy" {
      + id   = (known after apply)
      + json = (known after apply)

      + statement {
          + actions = [
              + "sts:AssumeRole",
            ]
          + sid     = "EKSWorkerAssumeRole"

          + principals {
              + identifiers = [
                  + "ec2.amazonaws.com",
                ]
              + type        = "Service"
            }
        }
    }

  # module.eks_blueprints.module.aws_eks_managed_node_groups["mg_5"].aws_iam_role.managed_ng[0] will be updated in-place
  ~ resource "aws_iam_role" "managed_ng" {
      ~ assume_role_policy    = jsonencode(
            {
              - Statement = [
                  - {
                      - Action    = "sts:AssumeRole"
                      - Effect    = "Allow"
                      - Principal = {
                          - Service = "ec2.amazonaws.com"
                        }
                      - Sid       = "EKSWorkerAssumeRole"
                    },
                ]
              - Version   = "2012-10-17"
            }
        ) -> (known after apply)
        id                    = "eks-argocd-karpenter-managed-ondemand"
        name                  = "eks-argocd-karpenter-managed-ondemand"
        tags                  = {
            "Blueprint"  = "eks-argocd-karpenter"
            "GithubRepo" = "github.com/aws-ia/terraform-aws-eks-blueprints"
        }
        # (9 unchanged attributes hidden)
    }

  # module.eks_blueprints.module.aws_eks_teams[0].aws_iam_policy.platform_team_eks_access[0] will be created
  + resource "aws_iam_policy" "platform_team_eks_access" {
      + arn         = (known after apply)
      + description = "Platform Team EKS Console Access"
      + id          = (known after apply)
      + name        = "eks-argocd-karpenter-PlatformTeamEKSAccess"
      + path        = "/"
      + policy      = jsonencode(
            {
              + Statement = [
                  + {
                      + Action   = [
                          + "ssm:GetParameter",
                          + "eks:ListUpdates",
                          + "eks:ListNodegroups",
                          + "eks:ListFargateProfiles",
                          + "eks:ListClusters",
                          + "eks:DescribeNodegroup",
                          + "eks:DescribeCluster",
                          + "eks:AccessKubernetesApi",
                        ]
                      + Effect   = "Allow"
                      + Resource = "arn:aws:eks:us-west-2:263022081217:cluster/eks-argocd-karpenter"
                      + Sid      = "AllowPlatformTeamEKSAccess"
                    },
                  + {
                      + Action   = "eks:ListClusters"
                      + Effect   = "Allow"
                      + Resource = "*"
                      + Sid      = "AllowListClusters"
                    },
                ]
              + Version   = "2012-10-17"
            }
        )
      + policy_id   = (known after apply)
      + tags        = {
          + "Blueprint"  = "eks-argocd-karpenter"
          + "GithubRepo" = "github.com/aws-ia/terraform-aws-eks-blueprints"
        }
      + tags_all    = {
          + "Blueprint"  = "eks-argocd-karpenter"
          + "GithubRepo" = "github.com/aws-ia/terraform-aws-eks-blueprints"
        }
    }

  # module.eks_blueprints.module.aws_eks_teams[0].aws_iam_role.platform_team["admin"] will be created
  + resource "aws_iam_role" "platform_team" {
      + arn                   = (known after apply)
      + assume_role_policy    = jsonencode(
            {
              + Statement = [
                  + {
                      + Action    = "sts:AssumeRole"
                      + Effect    = "Allow"
                      + Principal = {
                          + AWS = [
                              + "arn:aws:iam::263022081217:user/ahamadmin",
                            ]
                        }
                    },
                ]
              + Version   = "2012-10-17"
            }
        )
      + create_date           = (known after apply)
      + force_detach_policies = false
      + id                    = (known after apply)
      + managed_policy_arns   = (known after apply)
      + max_session_duration  = 3600
      + name                  = "eks-argocd-karpenter-admin-access"
      + name_prefix           = (known after apply)
      + path                  = "/"
      + tags                  = {
          + "Blueprint"  = "eks-argocd-karpenter"
          + "GithubRepo" = "github.com/aws-ia/terraform-aws-eks-blueprints"
        }
      + tags_all              = {
          + "Blueprint"  = "eks-argocd-karpenter"
          + "GithubRepo" = "github.com/aws-ia/terraform-aws-eks-blueprints"
        }
      + unique_id             = (known after apply)

      + inline_policy {
          + name   = (known after apply)
          + policy = (known after apply)
        }
    }

  # module.eks_blueprints.module.aws_eks_teams[0].aws_iam_role.team_access["team-marble"] will be created
  + resource "aws_iam_role" "team_access" {
      + arn                   = (known after apply)
      + assume_role_policy    = jsonencode(
            {
              + Statement = [
                  + {
                      + Action    = "sts:AssumeRole"
                      + Effect    = "Allow"
                      + Principal = {
                          + AWS = [
                              + "arn:aws:iam::263022081217:user/ahamadmin",
                            ]
                        }
                    },
                ]
              + Version   = "2012-10-17"
            }
        )
      + create_date           = (known after apply)
      + force_detach_policies = false
      + id                    = (known after apply)
      + managed_policy_arns   = (known after apply)
      + max_session_duration  = 3600
      + name                  = "eks-argocd-karpenter-team-marble-access"
      + name_prefix           = (known after apply)
      + path                  = "/"
      + tags                  = {
          + "Blueprint"  = "eks-argocd-karpenter"
          + "GithubRepo" = "github.com/aws-ia/terraform-aws-eks-blueprints"
        }
      + tags_all              = {
          + "Blueprint"  = "eks-argocd-karpenter"
          + "GithubRepo" = "github.com/aws-ia/terraform-aws-eks-blueprints"
        }
      + unique_id             = (known after apply)

      + inline_policy {
          + name   = (known after apply)
          + policy = (known after apply)
        }
    }

  # module.eks_blueprints.module.aws_eks_teams[0].aws_iam_role.team_sa_irsa["team-marble"] will be created
  + resource "aws_iam_role" "team_sa_irsa" {
      + arn                   = (known after apply)
      + assume_role_policy    = jsonencode(
            {
              + Statement = [
                  + {
                      + Action    = "sts:AssumeRoleWithWebIdentity"
                      + Condition = {
                          + StringEquals = {
                              + "oidc.eks.us-west-2.amazonaws.com/id/49B392510EA3E9E1AE8E67FE9FC8134C:aud" = "sts.amazonaws.com"   
                              + "oidc.eks.us-west-2.amazonaws.com/id/49B392510EA3E9E1AE8E67FE9FC8134C:sub" = "system:serviceaccount:team-marble:team-marble-sa"
                            }
                        }
                      + Effect    = "Allow"
                      + Principal = {
                          + Federated = "arn:aws:iam::263022081217:oidc-provider/oidc.eks.us-west-2.amazonaws.com/id/49B392510EA3E9E1AE8E67FE9FC8134C"
                        }
                    },
                ]
              + Version   = "2012-10-17"
            }
        )
      + create_date           = (known after apply)
      + force_detach_policies = false
      + id                    = (known after apply)
      + managed_policy_arns   = (known after apply)
      + max_session_duration  = 3600
      + name                  = "eks-argocd-karpenter-team-marble-sa-role"
      + name_prefix           = (known after apply)
      + path                  = "/"
      + tags                  = {
          + "Blueprint"  = "eks-argocd-karpenter"
          + "GithubRepo" = "github.com/aws-ia/terraform-aws-eks-blueprints"
        }
      + tags_all              = {
          + "Blueprint"  = "eks-argocd-karpenter"
          + "GithubRepo" = "github.com/aws-ia/terraform-aws-eks-blueprints"
        }
      + unique_id             = (known after apply)

      + inline_policy {
          + name   = (known after apply)
          + policy = (known after apply)
        }
    }

  # module.eks_blueprints.module.aws_eks_teams[0].kubectl_manifest.team["kubernetes/team-marble/limit-range.yaml"] will be created
  + resource "kubectl_manifest" "team" {
      + api_version             = "v1"
      + apply_only              = false
      + force_conflicts         = false
      + force_new               = false
      + id                      = (known after apply)
      + kind                    = "LimitRange"
      + live_manifest_incluster = (sensitive value)
      + live_uid                = (known after apply)
      + name                    = "resource-limits"
      + namespace               = "team-marble"
      + server_side_apply       = false
      + uid                     = (known after apply)
      + validate_schema         = true
      + wait_for_rollout        = true
      + yaml_body               = (sensitive value)
      + yaml_body_parsed        = <<-EOT
            apiVersion: v1
            kind: LimitRange
            metadata:
              name: resource-limits
              namespace: team-marble
            spec:
              limits:
              - default:
                  cpu: 300m
                  memory: 200Mi
                defaultRequest:
                  cpu: 200m
                  memory: 100Mi
                max:
                  cpu: "2"
                  memory: 1Gi
                maxLimitRequestRatio:
                  cpu: "10"
                min:
                  cpu: 50m
                  memory: 4Mi
                type: Container
        EOT
      + yaml_incluster          = (sensitive value)
    }

  # module.eks_blueprints.module.aws_eks_teams[0].kubernetes_cluster_role.team["team-marble"] will be created
  + resource "kubernetes_cluster_role" "team" {
      + id = (known after apply)

      + metadata {
          + generation       = (known after apply)
          + name             = "team-marble-team-cluster-role"
          + resource_version = (known after apply)
          + uid              = (known after apply)
        }

      + rule {
          + api_groups = [
              + "",
            ]
          + resources  = [
              + "namespaces",
              + "nodes",
            ]
          + verbs      = [
              + "get",
              + "list",
              + "watch",
            ]
        }
    }

  # module.eks_blueprints.module.aws_eks_teams[0].kubernetes_cluster_role_binding.team["team-marble"] will be created
  + resource "kubernetes_cluster_role_binding" "team" {
      + id = (known after apply)

      + metadata {
          + generation       = (known after apply)
          + name             = "team-marble-team-cluster-role-binding"
          + resource_version = (known after apply)
          + uid              = (known after apply)
        }

      + role_ref {
          + api_group = "rbac.authorization.k8s.io"
          + kind      = "ClusterRole"
          + name      = "team-marble-team-cluster-role"
        }

      + subject {
          + api_group = "rbac.authorization.k8s.io"
          + kind      = "Group"
          + name      = "team-marble-group"
          + namespace = "default"
        }
    }

  # module.eks_blueprints.module.aws_eks_teams[0].kubernetes_namespace.team["team-marble"] will be created
  + resource "kubernetes_namespace" "team" {
      + id = (known after apply)

      + metadata {
          + generation       = (known after apply)
          + labels           = {
              + "appName"     = "marble-team-app"
              + "billingCode" = "example"
              + "branch"      = "example"
              + "domain"      = "example"
              + "environment" = "dev"
              + "projectName" = "project-marble"
              + "uuid"        = "example"
            }
          + name             = "team-marble"
          + resource_version = (known after apply)
          + uid              = (known after apply)
        }
    }

  # module.eks_blueprints.module.aws_eks_teams[0].kubernetes_resource_quota.this["team-marble"] will be created
  + resource "kubernetes_resource_quota" "this" {
      + id = (known after apply)

      + metadata {
          + generation       = (known after apply)
          + name             = "quotas"
          + namespace        = "team-marble"
          + resource_version = (known after apply)
          + uid              = (known after apply)
        }

      + spec {
          + hard = {
              + "limits.cpu"      = "20000m"
              + "limits.memory"   = "50Gi"
              + "pods"            = "15"
              + "requests.cpu"    = "10000m"
              + "requests.memory" = "20Gi"
              + "secrets"         = "10"
              + "services"        = "10"
            }
        }
    }

  # module.eks_blueprints.module.aws_eks_teams[0].kubernetes_role.team["team-marble"] will be created
  + resource "kubernetes_role" "team" {
      + id = (known after apply)

      + metadata {
          + generation       = (known after apply)
          + name             = "team-marble-role"
          + namespace        = "team-marble"
          + resource_version = (known after apply)
          + uid              = (known after apply)
        }

      + rule {
          + api_groups = [
              + "*",
            ]
          + resources  = [
              + "configmaps",
              + "deployments",
              + "horizontalpodautoscalers",
              + "networkpolicies",
              + "pods",
              + "podtemplates",
              + "replicasets",
              + "secrets",
              + "serviceaccounts",
              + "services",
              + "statefulsets",
            ]
          + verbs      = [
              + "get",
              + "list",
              + "watch",
            ]
        }
      + rule {
          + api_groups = [
              + "*",
            ]
          + resources  = [
              + "resourcequotas",
            ]
          + verbs      = [
              + "get",
              + "list",
              + "watch",
            ]
        }
    }

  # module.eks_blueprints.module.aws_eks_teams[0].kubernetes_role_binding.team["team-marble"] will be created
  + resource "kubernetes_role_binding" "team" {
      + id = (known after apply)

      + metadata {
          + generation       = (known after apply)
          + name             = "team-marble-role-binding"
          + namespace        = "team-marble"
          + resource_version = (known after apply)
          + uid              = (known after apply)
        }

      + role_ref {
          + api_group = "rbac.authorization.k8s.io"
          + kind      = "Role"
          + name      = "team-marble-role"
        }

      + subject {
          + api_group = "rbac.authorization.k8s.io"
          + kind      = "Group"
          + name      = "team-marble-group"
          + namespace = "team-marble"
        }
    }

  # module.eks_blueprints.module.aws_eks_teams[0].kubernetes_service_account.team["team-marble"] will be created
  + resource "kubernetes_service_account" "team" {
      + automount_service_account_token = true
      + default_secret_name             = (known after apply)
      + id                              = (known after apply)

      + metadata {
          + annotations      = (known after apply)
          + generation       = (known after apply)
          + name             = "team-marble-sa"
          + namespace        = "team-marble"
          + resource_version = (known after apply)
          + uid              = (known after apply)
        }
    }

Plan: 12 to add, 2 to change, 0 to destroy.
module.eks_blueprints.module.aws_eks_teams[0].aws_iam_policy.platform_team_eks_access[0]: Creating...
module.eks_blueprints.module.aws_eks_teams[0].aws_iam_role.team_access["team-marble"]: Creating...
module.eks_blueprints.module.aws_eks_teams[0].aws_iam_role.team_sa_irsa["team-marble"]: Creating...
module.eks_blueprints.module.aws_eks_teams[0].kubernetes_cluster_role.team["team-marble"]: Creating...
module.eks_blueprints.module.aws_eks_teams[0].kubernetes_cluster_role_binding.team["team-marble"]: Creating...
module.eks_blueprints.module.aws_eks_teams[0].kubernetes_namespace.team["team-marble"]: Creating...
module.eks_blueprints.kubernetes_config_map.aws_auth[0]: Modifying... [id=kube-system/aws-auth]
module.eks_blueprints.module.aws_eks_teams[0].aws_iam_policy.platform_team_eks_access[0]: Creation complete after 8s [id=arn:aws:iam::263022081217:policy/eks-argocd-karpenter-PlatformTeamEKSAccess]
module.eks_blueprints.module.aws_eks_teams[0].aws_iam_role.platform_team["admin"]: Creating...
module.eks_blueprints.kubernetes_config_map.aws_auth[0]: Modifications complete after 2s [id=kube-system/aws-auth]
module.eks_blueprints.module.aws_eks_teams[0].kubernetes_cluster_role_binding.team["team-marble"]: Creation complete after 2s [id=team-marble-team-cluster-role-binding]
module.eks_blueprints.module.aws_eks_managed_node_groups["mg_5"].data.aws_iam_policy_document.managed_ng_assume_role_policy: Reading...
module.eks_blueprints.module.aws_eks_managed_node_groups["mg_5"].data.aws_iam_policy_document.managed_ng_assume_role_policy: Read complete after 0s [id=3778018924]
module.eks_blueprints.module.aws_eks_teams[0].kubernetes_cluster_role.team["team-marble"]: Creation complete after 3s [id=team-marble-team-cluster-role]
module.eks_blueprints.module.aws_eks_teams[0].kubernetes_namespace.team["team-marble"]: Creation complete after 3s [id=team-marble]
module.eks_blueprints.module.aws_eks_teams[0].aws_iam_role.team_sa_irsa["team-marble"]: Creation complete after 3s [id=eks-argocd-karpenter-team-marble-sa-role]
module.eks_blueprints.module.aws_eks_teams[0].kubernetes_role.team["team-marble"]: Creating...
module.eks_blueprints.module.aws_eks_teams[0].kubernetes_resource_quota.this["team-marble"]: Creating...
module.eks_blueprints.module.aws_eks_teams[0].kubernetes_role_binding.team["team-marble"]: Creating...
module.eks_blueprints.module.aws_eks_teams[0].kubectl_manifest.team["kubernetes/team-marble/limit-range.yaml"]: Creating...        
module.eks_blueprints.module.aws_eks_teams[0].aws_iam_role.team_access["team-marble"]: Creation complete after 9s [id=eks-argocd-karpenter-team-marble-access]
module.eks_blueprints.module.aws_eks_teams[0].kubernetes_service_account.team["team-marble"]: Creating...
module.eks_blueprints.module.aws_eks_teams[0].kubernetes_role_binding.team["team-marble"]: Creation complete after 1s [id=team-marble/team-marble-role-binding]
module.eks_blueprints.module.aws_eks_teams[0].kubernetes_role.team["team-marble"]: Creation complete after 1s [id=team-marble/team-marble-role]
module.eks_blueprints.module.aws_eks_teams[0].aws_iam_role.platform_team["admin"]: Creation complete after 2s [id=eks-argocd-karpenter-admin-access]
module.eks_blueprints.module.aws_eks_teams[0].kubernetes_resource_quota.this["team-marble"]: Creation complete after 3s [id=team-marble/quotas]
module.eks_blueprints.module.aws_eks_teams[0].kubernetes_service_account.team["team-marble"]: Creation complete after 4s [id=team-marble/team-marble-sa]
module.eks_blueprints.module.aws_eks_teams[0].kubectl_manifest.team["kubernetes/team-marble/limit-range.yaml"]: Creation complete after 5s [id=/api/v1/namespaces/team-marble/limitranges/resource-limits]

Apply complete! Resources: 12 added, 1 changed, 0 destroyed.

Outputs:

configure_kubectl = "aws eks --region us-west-2 update-kubeconfig --name eks-argocd-karpenter"
vpc_id = "vpc-0d9620716aff3efbf

There are several resources created when you onboard a team. including a Kubernetes Service Account created for the team. To view a full list, you can execute terraform state list and you should see resources similar to the ones shown below:

terraform state list module.eks_blueprints.module.aws_eks_teams

module.eks_blueprints.module.aws_eks_teams[0].data.aws_caller_identity.current
module.eks_blueprints.module.aws_eks_teams[0].data.aws_eks_cluster.eks_cluster
module.eks_blueprints.module.aws_eks_teams[0].data.aws_iam_policy_document.platform_team_eks_access[0]
module.eks_blueprints.module.aws_eks_teams[0].data.aws_partition.current
module.eks_blueprints.module.aws_eks_teams[0].data.aws_region.current
module.eks_blueprints.module.aws_eks_teams[0].aws_iam_policy.platform_team_eks_access[0]
module.eks_blueprints.module.aws_eks_teams[0].aws_iam_role.platform_team["admin"]
module.eks_blueprints.module.aws_eks_teams[0].aws_iam_role.team_access["team-marble"]
module.eks_blueprints.module.aws_eks_teams[0].aws_iam_role.team_sa_irsa["team-marble"]
module.eks_blueprints.module.aws_eks_teams[0].kubectl_manifest.team["kubernetes/team-marble/limit-range.yaml"]
module.eks_blueprints.module.aws_eks_teams[0].kubernetes_cluster_role.team["team-marble"]
module.eks_blueprints.module.aws_eks_teams[0].kubernetes_cluster_role_binding.team["team-marble"]
module.eks_blueprints.module.aws_eks_teams[0].kubernetes_namespace.team["team-marble"]
module.eks_blueprints.module.aws_eks_teams[0].kubernetes_resource_quota.this["team-marble"]
module.eks_blueprints.module.aws_eks_teams[0].kubernetes_role.team["team-marble"]
module.eks_blueprints.module.aws_eks_teams[0].kubernetes_role_binding.team["team-marble"]
module.eks_blueprints.module.aws_eks_teams[0].kubernetes_service_account.team["team-marble"]

# module.eks_blueprints.module.aws_eks_teams[0].aws_iam_role.platform_team["admin"]:
resource "aws_iam_role" "platform_team" {
    arn                   = "arn:aws:iam::263022081217:role/eks-argocd-karpenter-admin-access"
    assume_role_policy    = jsonencode(
        {
            Statement = [
                {
                    Action    = "sts:AssumeRole"
                    Effect    = "Allow"
                    Principal = {
                        AWS = [
                            "arn:aws:iam::263022081217:user/ahamadmin",
                        ]
                    }
                },
            ]
            Version   = "2012-10-17"
        }
    )
    create_date           = "2022-12-06T23:43:47Z"
    force_detach_policies = false
    id                    = "eks-argocd-karpenter-admin-access"
    managed_policy_arns   = [
        "arn:aws:iam::263022081217:policy/eks-argocd-karpenter-PlatformTeamEKSAccess",
    ]
    max_session_duration  = 3600
    name                  = "eks-argocd-karpenter-admin-access"
    path                  = "/"
    tags                  = {
        "Blueprint"  = "eks-argocd-karpenter"
        "GithubRepo" = "github.com/aws-ia/terraform-aws-eks-blueprints"
    }
    tags_all              = {
        "Blueprint"  = "eks-argocd-karpenter"
        "GithubRepo" = "github.com/aws-ia/terraform-aws-eks-blueprints"
    }
    unique_id             = "AROAT2PKWOTASWBF2T3OR"
}

Let's see how we can leverage the roles associated with our created Teams, in the next steps.


