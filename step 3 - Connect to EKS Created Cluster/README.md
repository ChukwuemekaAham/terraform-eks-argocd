### Connect to EKS Created Cluster

In the previous step, we created the EKS cluster, and the module outputs the kubeconfig information which we can use to connect to the cluster.

### Configure KubeConfig
The output configure_kubectl contains the command you can execute in your terminal to connect to the newly created cluster, example:

configure_kubectl = "aws eks --region us-west-2 update-kubeconfig --name eks-argocd-karpenter"

$ aws eks --region us-west-2 update-kubeconfig --name eks-argocd-karpenter
Added new context arn:aws:eks:us-west-2:263022081217:cluster/eks-argocd-karpenter to C:\Users\HP\.kube\config

Important
Copy the command from your own terraform output not the example above. The region value might be different.
Now we are connected on EKS with the super admin role which is our current role, the one that was used to create the cluster.

We can see the EKS auth configmap in order to see which roles are allowed to connect

kubectl get configmap -n kube-system aws-auth -o yaml > aws-auth


Connect to cluster as Team
At the time we created the EKS cluster, the current identity was automatically added to the Application team-marble Team thanks to the users parameter.

If you added additional IAM Role ARNs during the definition of team-marble, then you can safely assume that role as it was added to the auth configmap of the cluster.

If you want to get the command to configure kubectl for each team, you can add to the output to retrieve them.

Add those 2 outputs in output.tf


output "platform_teams_configure_kubectl" {
  description = "Configure kubectl for each Platform Team: make sure you're logged in with the correct AWS CLI profile and run the following command to update your kubeconfig"
  value       = try(module.eks_blueprints.teams[0].platform_teams_configure_kubectl["admin"], null)
}

output "application_teams_configure_kubectl" {
  description = "Configure kubectl for each Application Teams: make sure you're logged in with the correct AWS CLI profile and run the following command to update your kubeconfig"
  value       = try(module.eks_blueprints.teams[0].application_teams_configure_kubectl["team-marble"], null)
}


# Always a good practice to use a dry-run command
terraform plan


# apply changes to provision the Platform Team
terraform apply -auto-approve

You will see the kubectl to share with members of Team, copy the aws eks update-kubeconfig ... command portion of the output and run the command.

Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

application_teams_configure_kubectl = "aws eks --region us-west-2 update-kubeconfig --name eks-argocd-karpenter  --role-arn arn:aws:iam::263022081217:role/eks-argocd-karpenter-team-marble-access"

configure_kubectl = "aws eks --region us-west-2 update-kubeconfig --name eks-argocd-karpenter"

platform_teams_configure_kubectl = "aws eks --region us-west-2 update-kubeconfig --name eks-argocd-karpenter  --role-arn arn:aws:iam::263022081217:role/eks-argocd-karpenter-admin-access"

vpc_id = "vpc-0d9620716aff3efbf"

Important
Copy the command from your own terraform output not the example above. The region and account id values might be different.
Now you can execute kubectl CLI commands in the team-marble namespace.

Let's see if we can do same commands as previously ?


# list nodes ?
kubectl get nodes

NAME                                        STATUS   ROLES    AGE   VERSION
ip-10-0-10-106.us-west-2.compute.internal   Ready    <none>   87m   v1.23.13-eks-fb459a0
ip-10-0-11-156.us-west-2.compute.internal   Ready    <none>   87m   v1.23.13-eks-fb459a0
ip-10-0-12-82.us-west-2.compute.internal    Ready    <none>   87m   v1.23.13-eks-fb459a0

# List nodes in team-marble namespace ?
kubectl get pods -n team-marble

No resources found in team-marble namespace

# list all pods in all namespaces ?
kubectl get pods -A

NAMESPACE     NAME                       READY   STATUS    RESTARTS   AGE
kube-system   aws-node-6smll             1/1     Running   0          89m
kube-system   aws-node-cptkx             1/1     Running   0          89m
kube-system   aws-node-mrv28             1/1     Running   0          89m
kube-system   coredns-57ff979f67-mntr4   1/1     Running   0          94m
kube-system   coredns-57ff979f67-xq6gk   1/1     Running   0          94m
kube-system   kube-proxy-8wqpq           1/1     Running   0          89m
kube-system   kube-proxy-b4pbn           1/1     Running   0          89m
kube-system   kube-proxy-qpbcr           1/1     Running   0          89m

# can i create pods in kube-system namespace ?
kubectl auth can-i create pods --namespace kube-system
yes

# list service accounts in team-marble namespace ?
kubectl get sa -n team-marble

NAME             SECRETS   AGE
default          1         56m
team-marble-sa   1         56m

# list service accounts in default namespace ?
kubectl get sa -n default

NAME      SECRETS   AGE
default   1         96m

# can i create pods in team-marble namespace ?
kubectl auth can-i create pods --namespace team-marble
yes

# can i list pods in team-marble namespace ?
kubectl auth can-i list pods --namespace team-marble
yes

You can see here that our team-marble role, has read only rights in the cluster, but only in the team-marble namespace.

You can always see the quotas of your namespace with`


kubectl get resourcequotas -n team-marble   

NAME     AGE   REQUEST                                                                                  LIMIT
quotas   59m   pods: 0/15, requests.cpu: 0/10, requests.memory: 0/20Gi, secrets: 2/10, services: 0/10   limits.cpu: 0/20, limits.memory: 0/50Gi

It is best practice to not create kubernetes objects with kubectl directly but to rely on continuous deployment tools, we are going to see in the next step how we can leverage ArgoCD for that purpose!

Connect to cluster as Platform Admin
At the time we created the EKS cluster, the current identity was automatically added to the Platform Team as shown below.

  platform_teams = {
    admin = {
      users = [data.aws_caller_identity.current.arn]
    }
  }

Assuming you added additional IAM Role Arns, these would also have administrative access to the cluster, therefore you can assume said roles.

On the output you also see the kubectl to share with members of Platform Admin team, copy the aws eks update-kubeconfig ... command portion of the output and run the command.

platform_teams_configure_kubectl = "aws eks --region us-west-2 update-kubeconfig --name eks-argocd-karpenter  --role-arn arn:aws:iam::263022081217:role/eks-argocd-karpenter-admin-access"

Important
Copy the command from your own terraform output not the example above. The region and account id values might be different.
Now, let's check what we can do on the EKS cluster:


# list nodes ?
kubectl get nodes
# List nodes in team-marble namespace ?
kubectl get pods-n team-marble
# list all pods in all namespaces ?
kubectl get pods -A
# can i create pods in kube-system namespace ?
kubectl auth can-i create pods --namespace kube-system
# list service accounts in team-marble namespace ?
kubectl get sa -n team-marble
# list service accounts in default namespace ?
kubectl get sa -n default
# can i create pods in team-marble namespace ?
kubectl auth can-i create pods --namespace team-marble
# can i list pods in team-marble namespace ?
kubectl auth can-i list pods --namespace team-marble

This time there was no errors as we are using admin rights into our eks cluster.
OK, Now configure kubectl back to the current creator of the EKS cluster.

configure_kubectl = "aws eks --region us-west-2 update-kubeconfig --name eks-argocd-karpenter"

Important
Copy the command from your own terraform output not the example above. The region value might be different.



[Optional] Assume the Platform Admin Role in the AWS Console
You can also configure your AWS Console Role to assume the platform_team EKS admin role we created previously.

If you are doing it on your one, you may need to add instead the role you uses on the EKS console :

Add this in data.tf so that you can reference the AWS event TeamRole


# The TeamRole IAM role used when at AWS event
data "aws_iam_role" "team_event" {
  name = "myTeamRole"
}

Then update the platform_team definition in main.tf:


  platform_teams = {
    admin = {
      users = [
        data.aws_caller_identity.current.arn,
        data.aws_iam_role.team_event.arn
      ]
    }
  }

Add the role used by you in AWS console.

Then we can redeploy

terraform apply -auto-approve