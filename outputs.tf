output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "configure_kubectl" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = module.eks_blueprints.configure_kubectl
}

# At the time we created the EKS cluster, the current identity was automatically
# added to the Application team-riker Team thanks to the users parameter.

# If you added additional IAM Role ARNs during the definition of Team-Riker, 
# then you can safely assume that role as it was added to the auth configmap 
# of the cluster.

# If you want to get the command to configure kubectl for each team, you can 
# add to the output to retrieve them.

# Add the 2 outputs in output.tf as below

# Now redeploy with the new outputs

output "platform_teams_configure_kubectl" {
  description = "Configure kubectl for each Platform Team: make sure you're logged in with the correct AWS CLI profile and run the following command to update your kubeconfig"
  value       = try(module.eks_blueprints.teams[0].platform_teams_configure_kubectl["admin"], null)
}

output "application_teams_configure_kubectl" {
  description = "Configure kubectl for each Application Teams: make sure you're logged in with the correct AWS CLI profile and run the following command to update your kubeconfig"
  value       = try(module.eks_blueprints.teams[0].application_teams_configure_kubectl["team-marble"], null)
}
