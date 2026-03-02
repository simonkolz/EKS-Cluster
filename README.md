# EKS Cluster Deployment with ArgoCD, Helm Charts, Cert-Manager, and ExternalDNS

## Overview
This project provisions a production-grade Kubernetes cluster (EKS) on AWS using Terraform and deploys all platform components declaratively using Terraform-managed Helm releases.

## Key Features
- **Amazon EKS:** Managed Kubernetes service for running containerized applications at scale with high availability, security, and seamless AWS integration.
- **ArgoCD:** Declarative GitOps continuous delivery tool for Kubernetes, enabling automatic application deployment from Git repositories.
- **Helm Charts:** Simplifies the deployment and management of complex Kubernetes applications using reusable, version-controlled charts.
- **Cert-Manager:** Automates the management and issuance of TLS/SSL certificates within Kubernetes, integrated with ACME for automated renewals.
- **ExternalDNS:** Dynamically manages DNS records in AWS Route 53 based on Kubernetes resources, automating DNS record creation and updates.

## Why This Setup Matters

- **GitOps with ArgoCD:** Ensures consistent, version-controlled deployments through automated Git synchronization.
- **Scalable Infrastructure:** Utilizes EKS for auto-scaling and high availability.
- **Secure Communication:** Implements TLS/SSL for encrypted traffic with Cert-Manager.
- **Automated DNS Management:** ExternalDNS reduces manual effort by automating DNS configurations

All infrastructure and Kubernetes add-ons are provisioned via Terraform.

### 1. Configure AWS Credentials
```bash
aws configure
```
This command is used to set up your AWS credentials and default settings so you can interact with AWS services from your terminal.



### 2. Automate EKS Cluster and Helm Charts with Terraform
```bash
terraform init
terraform plan
terraform apply
```
This command initializes Terraform, previews the infrastructure changes, and deploys the EKS cluster and Helm Charts along with networking components.

### 3. Configure kubectl
```bash
aws eks --region <region> update-kubeconfig --name <cluster-name>
