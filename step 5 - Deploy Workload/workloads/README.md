Deploy Workload
Now that the cluster is ready and the Platform Team has onboarded the Application Team Riker, they are ready to deploy their workloads.

In the following exercise, you are going to work from your clone of eks-blueprints-workloads  repo, as a member of team Riker, and you will deploy your workloads only interacting with the git repo.

We will be deploying the team riker static site using ALB in this exercise.

Team Riker Objectives
The team has a static website that they need to publish. Changes should be tracked by source control using GitOps. This means that if a feature branch is merged into main branch, a “sync” is triggered and the app is updated seamlessly.

All of this work will be done within the Riker Team’s environment in EKS/Kubernetes.

The following is a list of key features of this workload:

A simple static website featuring great ski photography
In a real environment, we could add a custom FQDN and associated TLS Certificate, but in this lab we can't have custom domain, so we will stay in http on default domains.
As we mentioned earlier in our workshop, we use Helm to package apps and deploy workloads. The Workloads repository is the one recognized by ArgoCD (already setup by Platform Team).

Add App to Workloads Repo


Change target Application to your fork
Open your clone of the Workloads Repository in your IDE (or codespace)
Ensure you are on the main branch
In our workload_application configuration in locals.tf we previously configured it to uses the env/dev directory.

workload_application = {
  path               = "envs/dev"
  repo_url           = "https://github.com/[ PUT YOUR GITHUB USER HERE ]/eks-blueprints-workloads.git"
  add_on_application = false
}
So first, let's see the structure of this folder:

envs/dev/
├── Chart.yaml
├── templates
│   ├── team-burnham.yaml
│   ├── team-carmen.yaml
│   ├── team-geordi.yaml
│   └── team-riker.yaml
└── values.yaml
You can see that this structure is for a Helm Chart in which we define several teams workloads, so if you are familiar with Helm charts, kudos!

Important
We can see here that the demo repository we reuses has define 4 teams (which are ArgoCD kind Application), but in the Blueprint we only configure the Team Riker as for now. If we deploy as is, because we didn't restrict which namespace can be created using Argo, all thoses 4 teams will be created, but we only focus on the team-riker for now... So either we delete the other s tem-xxx.yaml files to focus on riker, or you can let Argo deploy thoses additionals worklaods but that can be confusing for you.
The env/dev/values.yaml configure the source repoURL that will be used by the ArgoCD Application definition. You need to update it with your Fork url


spec:
  destination:
    server: https://kubernetes.default.svc
  source:
    # <-- Change with your forked URL -->
    repoURL: https://github.com/[ PUT YOUR GITHUB USER HERE ]/eks-blueprints-workloads
    targetRevision: main
  ingress:
    host: dev.example.com

Now, let's have a look at the team-riker.yaml helm template file. It's an ArgoCD Application definition which specifies which repository and directory to use. The specified repository uses the one in the values.yaml you just changed, and the path is teams/team-riker/dev

So now, let's look under the teams/team-riker/dev directory structure.

├── Chart.yaml
├── templates
│   ├── deployment.yaml
│   ├── ingress.yaml
│   └── service.yaml
└── values.yaml
Again, it uses the Helm chart format.

The files under the templates directory are rendered using helm and deployed into the EKS cluster into the team-riker namespace.

Add our website manifest
In order to deploy our website, we will need to add some kubernetes manifests to the teams/team-riker/dev/templates directory. There are several ways to do it, you can clone your repo, edit, the files and pushed them back to github, you can uses GitHub Codespace to have a remote VsCode and make change there, or you can uses the GitHub interface to push your changes.

Create a new directory alb-skiapp and file deployment.yaml and copy the deployment.yaml  content.

Then do the same for the 2 remaining files service.yaml  and ingress.yaml 



1
2
# Always a good practice to use a dry-run command
terraform plan

1
2
# apply changes to provision the Platform Team
terraform apply -auto-approve

Since our changes are pushed to the main branch of our worload git repository, and Argo is now aware tof it, it will automatically sync the main branch with our EKS cluster. Your ArgoCD dashboard should look like the following.

If changes are not appearing, you may need to resync the workloads Application in ArgoCD UI: Click on workloads and click on the sync button.


You can Click in the ArgoUI on the team-riker box.

Then you will see all the kubernetes objects that are deployed in the team-riker namespace

To access our Ski App application, you now can click on the skiapp-ingress as shown in red in the previous picture.


Important
For a production application, we would have configure our ingress to use a custom domain name, and uses the external-dns add-on to dynamically configure our route53 hosted zone from the ingress configuration.


So our Riker Application Team as successfully published their website to the EKS cluster provided by the Platform Team. This pattern can be reused with your actual applications, If you want to see more EKS blueprints teams and ArgoCD integration, you can go to next module.

