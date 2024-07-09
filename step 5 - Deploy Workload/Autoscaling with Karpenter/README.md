### Autoscaling with Karpenter

In this module, you will learn how to maintain your Kubernetes clusters at any scale using Karpenter https://karpenter.sh/ .

Karpenter is an open-source autoscaling project built for Kubernetes. Karpenter is designed to provide the right compute resources to match your application’s needs in seconds, instead of minutes by observing the aggregate resource requests of unschedulable pods and makes decisions to launch and terminate nodes to minimize scheduling latencies.

Karpenter is a node lifecycle management solution used to scale your Kubernetes Cluster. It observes incoming pods and launches the right instances for the situation. Instance selection decisions are intent based and driven by the specification of incoming pods, including resource requests and scheduling constraints.

For now, our EKS blueprint cluster is configured to run with a Managed Node Group, which has deployed a minimum set of On-Demand instances that we will use to deploy Kubernetes controllers on it. After that we will use Karpenter to deploy a mix of On-Demand and Spot instances to showcase a few of the benefits of running a group-less auto scaler. EC2 Spot Instances allow you to architect for optimizations on cost and scale.


# Create the EC2 Spot Linked Role
We continue as Platform Team member and create the EC2 Spot Linked role https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/spot-requests.html#service-linked-roles-spot-instance-requests , which is necessary to exist in your account in order to let you launch Spot instances.

Important
This step is only necessary if this is the first time you’re using EC2 Spot in this account. If the role has already been successfully created, you will see: An error occurred (InvalidInput) when calling the CreateServiceLinkedRole operation: Service role name AWSServiceRoleForEC2Spot has been taken in this account, please try a different suffix. Just ignore the error and proceed with the rest of the workshop.

aws iam create-service-linked-role --aws-service-name spot.amazonaws.com


Add Karpenter Add-On
Karpenter can be configured using default, or advanced customizations via Launch Templates. You can see the EKS blueprint Karpenter example https://github.com/aws-ia/terraform-aws-eks-blueprints/tree/main/examples/karpenter  for more advanced configurations.

In our Terraform code in main.tf in kubernetes_addons changed the enable_karpenter to true and redeploy.

  enable_karpenter                    = true


Then, at the end of main.tf add the creation of our default Karpenter provisioner default-provisioner.yaml

and now, create the manifest inside the EKS blueprints folder:

mkdir kubernetes/karpenter
kubernetes/karpenter/default-provisioner.yaml


This creates a default provisioner that will create EKS nodes with dedicated labels, that can be used by Pods spec as nodeSelectors.

We also add taints to the nodes so that workloads will need to tolerate those taints to be scheduled on Karpenter's nodes.

You can create many different Karpenter provisioners, and even make it default for every additional workloads by removing the taint. You can also define priority between different provisioners, so that you can for instance uses in priority your nodes which benefits from AWS RIs... TODO



Deploy the Add-on
Now run Terraform plan to see our modifications.

1
terraform plan

Now run Terraform apply to deploy our modifications.

1
terraform apply --auto-approve

Once the deployment is done you should see Karpenter appears in the cluster:

1
kubectl get pods -n karpenter

NAME                         READY   STATUS    RESTARTS   AGE
karpenter-776657675b-d8sgt   2/2     Running   0          88s
karpenter-776657675b-gj8h4   2/2     Running   0          88s
We can also see the default provisioner:

1
kubectl get provisioner

NAME      AGE
default   8m33s
This provisioner will now be used by Karpenter when deploying workloads assuming a toleration for karpenter.

But, Actually we should have no Karpenter nodes in our cluster. let's check this with our alias to list our nodes:

1
2
3
kubectl get nodes
# or : 
#kubectl get nodes -L karpenter.sh/capacity-type -L topology.kubernetes.io/zone -L karpenter.sh/provisioner-name

NAME                                        STATUS   ROLES    AGE   VERSION                CAPACITY-TYPE   ZONE         PROVISIONER-NAME
ip-10-0-10-190.eu-west-1.compute.internal   Ready    <none>   14d   v1.21.12-eks-5308cf7                   eu-west-1a
ip-10-0-11-188.eu-west-1.compute.internal   Ready    <none>   14d   v1.21.12-eks-5308cf7                   eu-west-1b
ip-10-0-12-127.eu-west-1.compute.internal   Ready    <none>   14d   v1.21.12-eks-5308cf7                   eu-west-1c
We can see our actual Managed nodes groups, 1 in each AZ, and there should not be already nodes managed by Karpenter.

We need to scale our Karpenter Nodes with a dedicated workload, Let's do that!!

# Deploy Workload on Karpenter's nodes as part of Riker Application Team

Important
Now, we go back to our team-riker Application Team role, and we are going to work again in our workload git repository fork.
Go to teams/team-riker/dev/templates/ directory and add a manifest to deploy the 2048 Game:

Copy the manifest from the assets, it is composed of:

a deployment, with
nodeSelector to Karpenter nodes
toleration for Karpenter taints
topologySpradConstraints to spread our workloads on each AZ
a Service
an ALB ingress configured in HTTP only (again, in production uses TLS certificates!!)




Then git add this file, and commit to your fork, then go to ArgoCD UI and Sync the deployment, or wait few minutes, for it to be sync automatically.

Once ArgoCD has synchronized, you should see the 2048 game deployed

Check deployment
After few minutes you should see the 2048 pods:

1
kubectl get pods -A | grep 2048

team-riker         deployment-2048-668d667b4c-5nk5d                            1/1     Running   0          6s
team-riker         deployment-2048-668d667b4c-787mn                            0/1     Pending   0          6s
team-riker         deployment-2048-668d667b4c-bqshw                            1/1     Running   0          6s
We should have 3 pods, 1 in each AZ

You can get the ingress of the game and start playing :)

1
kubectl get ing -A | grep 2048

team-riker         ingress-2048       alb     *       k8s-teamrike-ingress2-5390269848-1279299872.eu-west-1.elb.amazonaws.com   80      85s
So where the pods were scheduled onto ? check again the nodes

1
2
3
kgn
# .. or 
# kubectl get nodes -L karpenter.sh/capacity-type -L topology.kubernetes.io/zone -L karpenter.sh/provisioner-name

NAME                                        STATUS   ROLES    AGE   VERSION                CAPACITY-TYPE   ZONE         PROVISIONER-NAME
ip-10-0-10-190.eu-west-1.compute.internal   Ready    <none>   14d     v1.21.12-eks-5308cf7                   eu-west-1a
ip-10-0-10-40.eu-west-1.compute.internal    Ready    <none>   6m18s   v1.21.12-eks-5308cf7   spot            eu-west-1a   default
ip-10-0-11-188.eu-west-1.compute.internal   Ready    <none>   14d     v1.21.12-eks-5308cf7                   eu-west-1b
ip-10-0-11-91.eu-west-1.compute.internal    Ready    <none>   6m18s     v1.21.12-eks-5308cf7   spot            eu-west-1b   default
ip-10-0-12-127.eu-west-1.compute.internal   Ready    <none>   14d     v1.21.12-eks-5308cf7                   eu-west-1c
ip-10-0-10-97.eu-west-1.compute.internal    Ready    <none>   6m18s     v1.21.12-eks-5308cf7   spot            eu-west-1c   default
You should see that we have 3 additional Spot nodes, deployed with the default provisioner, one in each availability zone.

As a Team Riker Team member, we have successfully leverage Karpenter's ability to schedule our workloads from our ArgoCD git repository only, and dynamically adapt our cluster size depending on our needs.

Important
Remember that we set Quotas to our namespaces, we can't actually launch more that 10 pods in team-riker namespace. We can ask Platform Team to adjust quotas in main.tf to adapt to our needs
