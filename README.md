# Introduction

In this section, we will go over the following topics to ensure that we have a fundamental understanding of what EKS Blueprints are along with the benefits of building one on Amazon EKS.
We will discuss the following:

1.	What is EKS Blueprints?
2.	What are the components and tools used in order to build EKS Blueprints?
3.	What are the benefits of using EKS Blueprints?
4.	How do different personas, i.e platform teams and application teams, leverage EKS Blueprints?
5.	What is a reference architecture diagram for EKS Blueprints?
6.	How are compute infrastructure defined, and how do you provision and manage it across environments using EKS Blueprints?
7.	How are teams onboarded to the EKS Blueprints, and then supplied control to access shared EKS clusters?
8.	How are workloads in multiple environments onboarded to the EKS Blueprints?
9.	In the next section, we will cover what EKS Blueprints is.


### Benefits of EKS Blueprints

Why leverage the EKS Blueprints?

The ecosystem of tools that have developed around Kubernetes and the Cloud Native Computing Foundation (CNCF) provides cloud engineers with a wealth of choice when it comes to architecting their infrastructure. Determining the right mix of tools and services however, in addition to how they integrate, can be a challenge. As your Kubernetes estate grows, managing configuration for your clusters can also become a challenge.

AWS customers are building internal platforms to tame this complexity, automate the management of their Kubernetes environments, and make it easy for developers to onboard their workloads. However, these platforms require investment of time and engineering resources to build. 

*The goal of this project* is to provide customers with a tool chain that can help them deploy a platform on top of EKS with ease and best practice. EKS Blueprints provide logical abstractions and prescriptive guidance for building a platform. Ultimately, we want to help EKS customers accelerate time to market for their own platform initiatives.

## Separation of Concerns - Platform Teams vs Application Teams

Platform teams build the tools that provision, manage, and secure the underlying infrastructure while application teams are free to focus on building the applications that deliver business value to customers. Application teams need to focus on writing code and quickly shipping product, but there must be certain standards that are uniform across all production applications to make them secure, compliant, and highly available.

EKS Blueprints provide a better workflow between platform and application teams, and also provide a self-service interface for developers to use, that is streamlined for developing code. The platform teams have full control to define standards on security, software delivery, monitoring, and networking that must be used across all applications deployed. 

This allows developers to be more productive because they don’t have to configure and manage the underlying cloud resources themselves. It also gives operators more control in making sure production applications are secure, compliant, and highly available.

What does good look like?

EKS Blueprints will look slightly different between organizations depending on the requirements, but all of them look to solve the same set of problems listed below:

Challenge	                                      |                             Solution provided by EKS Blueprints
Developers wait days / weeks for infrastructure to be provisioned |	Developers provision infrastructure on demand and deploy in minutes
Software is manually deployed on an ad-hoc basis	| Software delivery is automated via continuous delivery pipelines
Security is configured ad-hoc for each application |	Security best practices are baked in to every application and service
Developers lack visibility into applications running in production	| Applications are fully instrumented for metric and log collection

Tooling is inconsistent across teams and business units	Organizations standardize on tools and best practices
The reason why you would want to do this on top of AWS is because of the breadth of services offered by AWS paired with the vast open-source ecosystem backed by the Kubernetes community provides a limitless number of different combination of services and solutions to meet your specific requirements and needs. It is much easier to think about the benefits in the context of core principals that EKS Blueprints was built upon which include the following:

•	Security and Compliance
•	Cost Management
•	Deployment Automation
•	Provisioning of infrastructure
•	Telemetry

In the next section, we will talk about the different personas that are involved by leveraging EKS Blueprints.

How does it affect different individuals?

What can each individual on your teams expect from EKS Blueprints?

Now that we have an understanding of why we are using the EKS Blueprints, let's take some time to understand how this will benefit the various roles on each team that we will be working with.
Team topologies vary by environment, however one topology that is prevalent across many organizations, is having a Platform Team managing infrastructure provisioning. And also having multiple Application Teams that need to focus on deploying features in an agile manner.

Many companies face a big challenge in enabling multiple developer teams to freely consume a platform with proper guardrails. The objective of our workshop is to show you how you can provision a platform based on EKS to remove these barriers.

## The workshop focuses on two key enterprise teams, a Platform Team and a Application Team.

- The Platform Team will provision the EKS cluster and onboard the Developer Team. 
- The Application Team will deploy a workload to the cluster.

***Platform Team**

Acting as the Platform Team, we will use the EKS Blueprints for Terraform  which is a solution entirely written in Terraform HCL language. It helps you build a shared platform where multiple teams can consume and deploy their workloads. The EKS underlying technology is Kubernetes of course, so having some experience with Terraform and Kubernetes is helpful. You will be guided by our AWS experts (on-site) as you follow along on this workshop.

**Application Team**

Once the EKS Cluster has been provisioned, a Application Team (Riker Team) will deploy a workload. The workload is a basic static web app. The static site will be deployed using GitOps continuous delivery.


