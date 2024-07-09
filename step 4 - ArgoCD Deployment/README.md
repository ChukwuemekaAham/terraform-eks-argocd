Working with GitOps: Bootstrap ArgoCD
In this step, we are going to bootstrap ArgoCD  as our GitOps engine. We will indicate in our configurations that we want to use our forked workloads repository. What this means, is that any apps the Developer Teams want to deploy, will need to be defined in this repository so that ArgoCD is aware.

ℹ️ You can learn more about ArgoCD and how it implements GitOps here 
https://argo-cd.readthedocs.io/en/stable/.

We will also configure the eks-blueprints-add-ons repository to manage the EKS Kubernetes add-ons for our cluster, using ArgoCD. Deploying the Kubernetes add-ons with GitOps has several advantages, like their state will always be synchronized with the git repository thanks to the ArgoCD controller.

We will also reuse a git repository containing sample workload to deploy with ArgoCDD eks-blueprints-workloads

Fork both the add-on and workload repositories.

Go to https://github.com/aws-samples/eks-blueprints-add-ons.git  and fork it.
Go to https://github.com/aws-samples/eks-blueprints-workloads.git  and fork it.
Add argo application config for both repositories, eks add-on and your forked of workload repository
The first thing we need to do, is augment our locals.tf with the two new variables addon_application and workload_application as shown below.

Replace the entire contents of the locals.tf with the code below.

Update the repo_url for both the workload repository with your fork replacing [YOUR GITHUB USER HERE].

Add Kubernetes Addons Terraform module to main.tf

Add the kubernetes_addons module at the end of our main.tf. To indicate that ArgoCD should responsible for managing cluster add-ons, we uses the argocd_manage_add_ons property to true (see below). When this flag is set, the framework will still provision all AWS resources necessary to support add-on functionalities (IAM Roles, IAM Policies, dependant resources..), but it will not apply Helm charts directly via the Terraform Helm provider, and let Argo do it.

We also specify a custom set to configure Argo to expose ArgoCD UI on an aws load balancer. (ideallly we should do it using an ingress but this will be easier for this lab)

This will configure ArgoCD add-on, and allow it to deploy additional kubernetes add-ons using GitOps.

Copy this at the end of main.tf


Now that we’ve added the kubernetes_addons module, and have configured ArgoCD, we will apply our changes.

# we added a new module, so we must init
terraform init

# Always a good practice to use a dry-run command
terraform plan

# apply changes to provision the Platform Team
terraform apply -auto-approve


Validate ArgoCD deployment
To validate that ArgoCD is now in our cluster, we can execute the following:

kubectl get all -n argocd

Wait about 2 minutes for the LoadBalancer creation, and get it's URL:


export ARGOCD_SERVER=`kubectl get svc argo-cd-argocd-server -n argocd -o json | jq --raw-output '.status.loadBalancer.ingress[0].hostname'`
echo "https://$ARGOCD_SERVER"

Open a new browser and paste in the url from the previous command. You will now see the ArgoCD UI.

Important
Since ArgoCD UI exposed like this is using self-signed certificate, you'll need to accept the security exception in your browser to access it.

Retrieve the generated secret for ArgoCD UI admin password.
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d


Login to the UI:

The username is admin
The password is: the result of the Query for admin password command above.

At this step you should be able to see Argo UI

(Note: we could also instead have created a Secret Manager Password for Argo with terraform see example https://github.com/aws-ia/terraform-aws-eks-blueprints/blob/main/examples/gitops/argocd/main.tf#L77)

For any future available (https://aws-ia.github.io/terraform-aws-eks-blueprints/add-ons/) add-ons you wish to enable, simply follow the steps above by modifying the kubernetes_addons module within the main.tf file and terraform apply again.

In the ArgoUI, you can see that we have severals Applications deployed:

addons
aws-load-balancer-controller
aws_for_fluentbit
metrics_server

Important
We declare 4 add-ons but only 3 are listed in ArgoUI ?


The EKS Blueprint can deploy Add-ons through EKS managed (https://docs.aws.amazon.com/eks/latest/userguide/eks-add-ons.html) add-ons  when they are available, which is the case for the EBS CSI driver. (enable_amazon_eks_aws_ebs_csi_driver = true) In this case it's not ArgoCD that managed thems.

We will now work as a member of team Riker for next module of the workshop.