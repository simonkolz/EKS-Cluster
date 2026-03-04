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



### 2. Automate EKS Cluster with Terraform
```bash
terraform init
terraform plan
terraform apply
```
This command initializes Terraform, previews the infrastructure changes, and deploys the EKS cluster along with networking components.

### 3. Configure kubectl
```bash
aws eks --region <region> update-kubeconfig --name <cluster-name>
```
This command is used to connect your local machine’s kubectl to your EKS cluster.

### 4.  Deply Helm Charts to deploy tools like cert-manager, NGINX Ingress Controller and externalDNS with Terraform

Create your NGINX Ingress Controller, Cert-manager and ExternalDNS with the following:
- **"helm.tf"**
- **"helm-values/cert-manager.yaml"**
- **"helm-vaules/external-dns.yaml"**

Then run
```bash
terraform plan
terraform apply
```
### 5. Add Cluster Issuer for Cert-manager

Create your Cluster Issuer file with the following:
- **"cert-man/issuer.yaml"**

Then run:
```bash
kubectl apply -f cert-man/issuer.yaml
```
This command will create your cluster issuer for your cert-manager within your cluster using the file "cert-man/issuer.yaml"

### 6. Deploy ArgoCD with Terrafrom
Deploy ArgoCD with the following:
- Adding the **"argocd_deploy"** helm release resource to the **helm.tf** file
- Create **"helm-values/argocd.yaml"** to customizes how the Argo CD server is exposed and secured in your Kubernetes cluster.

 Then run:
 ```bash
terraform plan
terraform apply
kubectl get ingress -A
```
These commands will deploy your ArgoCD and show you the host used to access it on your browser

<img width="1025" height="58" alt="Screenshot 2026-03-04 at 14 35 21" src="https://github.com/user-attachments/assets/1de0209a-6b50-44e5-9d36-29074aed9c47" />

<img width="1440" height="857" alt="Screenshot 2026-03-04 at 14 54 20" src="https://github.com/user-attachments/assets/270bb0d4-16d5-4e8d-9458-90be488cda29" />


