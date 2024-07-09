Blue/Green Deployments with Argo Rollouts
In this module, we use Argo Rollouts to implement an advanced deployment strategy called blue-green. There are many benefits in using this strategy including zero downtime deployments.

The Kubernetes Deployment already uses rolling updates but does not give you enough control. Here is a comparison.

Features	Kubernetes Deployment	Argo Rollouts
Blue/Green	No	Yes
Control over Rollout Speed	No	Yes
Easy traffic Management	No	Yes
Verify using External Metrics	No	Yes
Automate Rollout/rollback based on analysis	No	Yes

**Important**
This workshop is focused on how to enable and try Argo Rollouts in the context of using EKS Blueprints for Terraform We do not provide a deep-dive into Argo Rollouts. To learn more about Argo Rollouts view the docs https://argoproj.github.io/argo-rollouts/concepts/#rollout


## How Argo Rollouts Blue/Green Deployments Work
The Rollout will configure the preview service (Green) to send traffic to the new version while the active service (Blue) continues to receive production traffic. Once we are satisfied, we promote the preview service to be the new active service.

image.png

## Scenario
Marketing would like to run functional testing on a new version of the Skiapp before it starts to serve production traffic.

The current version we are using is sharepointoscar/skiapp:v1 which is pulled from Docker Hub. The new and improved version is appropriately tagged sharepointoscar/skiapp:v2 and includes less global navigation items.

Marketing decided there were too many global navigation items.

## Enable Argo Rollouts Add-on
Earlier in the Bootstrap ArgoCD section, we added the kubernetes_addons module. We enabled several add-ons using the EKS Blueprints for Terraform IaC. Argo Rollouts comes out of the box as an add-on, so all we need to do is enable it.

Go to the main.tf file and under the kubernetes_addons module. Add the enable_argo_rollouts, enable the add-onm then add the helm configuration as shown below.


### Next apply our changes via Terraform.

`terraform apply -auto-approve`

Validate Argo Rollouts Installation
One of the first things to check is the new namespace argo-rollouts


`kubectl get all -n argo-rollouts`

```bash

NAME                                 READY   STATUS    RESTARTS   AGE
pod/argo-rollouts-5656b86459-j9bjg   1/1     Running   0          3h38m
pod/argo-rollouts-5656b86459-rhthq   1/1     Running   0          3h38m

NAME                            READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/argo-rollouts   2/2     2            2           3h38m

NAME                                       DESIRED   CURRENT   READY   AGE
replicaset.apps/argo-rollouts-5656b86459   2         2         2       3h38m


```
**The ArgoCD dashboard should also show you the installation is green and all items are healthy.**

### Accessing ArgoCD UI
For instructions on how to access the ArgoCD UI, take a look at our previous steps. Bootstrap ArgoCD https://catalog.workshops.aws/eks-blueprints-terraform/030-provision-eks-cluster/6-bootstrap-argocd#validate-deployments-via-kubectl



# Deploy App Using Blue/Green Strategy
Now that we have Argo Rollouts fully configured, it is time to take it for a spin.

Using the skiapp we previously used, we are going to deploy using the blue-green deployment strategy.

Let's define the Rollout!


## Add rollout.yaml to alb-skiapp folder
In our previous module Add App to Workloads Repo https://catalog.workshops.aws/eks-blueprints-terraform/en-US/040-dev-team-deploy-workload/1-add-app-to-workloads-repo.md , we created the alb-skiapp folder and added the ingress.yaml, deployment.yaml and service.yaml files.

We now need to add an additional file called rollout.yaml to that folder and we will end up with the following structure.

├── Chart.yaml
├── templates
│   ├── alb-skiapp
│   │   ├── deployment.yaml
│   │   ├── ingress.yaml
│   │   ├── rollout.yaml
│   │   └── service.yaml
│   ├── deployment.yaml
│   ├── ingress.yaml
│   └── service.yaml
└── values.yaml

Once you've located the workloads repository and alb-skiapp folder, let's add additional file to define the Rollout.

## Add Rollout YAML definition
Inside the alb-skiapp folder, add the following definition in a new file named rollout.yaml. We are adding 3 different resources, which include a Rollout, a Service to use for the Preview of our app, and lastly we create an Ingress to use with our Preview Service.


Save the file in your source code.

```bash
git add .
git commit -m "feature: adding rollout resource"
git push
```

Go to the Argo Dashboard and see the Rollout deploy. If it is not deployed yet, you can click on the Sync button to force it.

**Install Argo Rollouts Kubectl plugin by following instructions here .**

For Linux use this command

```bash
sudo curl -Lo /usr/local/bin/kubectl-argo-rollouts https://github.com/argoproj/argo-rollouts/releases/latest/download/kubectl-argo-rollouts-linux-amd64

sudo chmod +x /usr/local/bin/kubectl-argo-rollouts
```

Then, you can also check the status of the Rollout with the following command:

```bash
kubectl argo rollouts list rollouts -n team-riker

NAME            STRATEGY   STATUS        STEP  SET-WEIGHT  READY  DESIRED  UP-TO-DATE  AVAILABLE
skiapp-rollout  BlueGreen  Healthy       -     -           3/3    3        3           3    

```
## Deploy a Green Version of Skiapp

Now that we have our Blue version running of the skiapp, we want to deploy a Green version which visually has the top navigation changed, we've removed several items from the navigation menu.

**Update Rollout in Source Control**
Since our Rollout definition is within our Workloads repo, let's change the image used, and set it to V2 (Green).

In the rollout.yaml, change the image to sharepointoscar/skiapp:v2 as shown below.

**NOTE:** You can copy the entire definition of the Rollout and paste it in your source control file, or simply change the container version directly. It should look like the Rollout defined below.

Once you've checked in the file in source control and merged with the main branch, ArgoCD will pick up the change and sync and update the Rollout so that the Preview Service shows the (Green) v2 version of our app.

You can check the status on either the ArgoCD Dashboard, or the Argo Rollouts Dashboard.

**To be able to open the Argo Rollout Dashboard inside Cloud9, we need to forward port 8080 to 3100**

```bash
sudo iptables -t nat -I OUTPUT -o lo -p tcp --dport 8080 -j REDIRECT --to-port 3100
sudo iptables -I INPUT -p tcp --dport 3100
sudo iptables -I INPUT -p tcp --dport 8080
```

**Let's take a look where we are with the Argo Rollouts Dashboard using the following command.**


`kubectl argo rollouts dashboard`

- Open the Browser Preview by using the menu option Tools > Preview > Preview Running Application.

At this point, our Rollout is paused. It is during this time when folks on the design team can view the Green version of the app, to test it etc.

*Important*
To obtain the Preview Ingress URL, simply login to the **ArgoCD UI** or use `kubectl get ing -n team-riker`

*Assuming you have an approval to go live with the Green version of the app, we simply Promote the version via the Argo Rollouts dashboard. Our v2 version of the app is now the Blue and stable and active version.*


**You can also do it with the Cli**

`kubectl argo rollouts promote skiapp-rollout -n team-riker`


**Rolling Back to V1**

Rolling back to a previous version is as easy as clicking the Rollback button on the Argo Rollouts Dashboard. You can also do that via the kubectl CLI, or the ArgoCD Admin web console.

You can also do it with the CLI

`kubectl argo rollouts undo skiapp-rollout -n team-riker`

