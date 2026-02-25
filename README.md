# EKS Cluster Deployment with ArgoCD, Helm Charts, Cert-Manager, and ExternalDNS

## Overview
This project provisions a production-grade Kubernetes cluster (EKS) on AWS using Terraform and deploys all platform components declaratively using Terraform-managed Helm releases.

## Key Features
- **Amazon EKS:** Managed Kubernetes service for running containerized applications at scale with high availability, security, and seamless AWS integration.
- **ArgoCD:** Declarative GitOps continuous delivery tool for Kubernetes, enabling automatic application deployment from Git repositories.
- **Helm Charts:** Simplifies the deployment and management of complex Kubernetes applications using reusable, version-controlled charts.
- **Cert-Manager:** Automates the management and issuance of TLS/SSL certificates within Kubernetes, integrated with ACME for automated renewals.
- **ExternalDNS:** Dynamically manages DNS records in AWS Route 53 based on Kubernetes resources, automating DNS record creation and updates.

## 🏗️ Architecture

All infrastructure and Kubernetes add-ons are provisioned via Terraform.

**Infrastructure Layer (AWS)**

Provisioned using Terraform:

VPC (Multi-AZ)

Public subnets

Private subnets

NAT Gateway

Internet Gateway

EKS Cluster

Managed Node Group

IAM Roles

OIDC Provider (for IRSA)

KMS encryption for secrets

Security Groups

Route53 Hosted Zone (if applicable)
Kubernetes provider

Helm provider

Helm releases

ArgoCD installation

DNS + SSL automation components

No manual helm install commands were used.

### 2. Provision EKS Cluster with Terraform
```bash
terraform init
terraform plan
terraform apply
```
This command initializes Terraform, previews the infrastructure changes, and deploys the EKS cluster along with networking components.

### 3. Configure kubectl
```bash
aws eks --region <region> update-kubeconfig --name <cluster-name>
