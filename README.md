# EKS Cluster Deployment with ArgoCD, Helm Charts, Cert-Manager, and ExternalDNS

## Overview
This project provisions a production-grade Kubernetes cluster (EKS) on AWS using Terraform and deploys all platform components declaratively using Terraform-managed Helm releases.

## Architecture
<img width="911" height="639" alt="Screenshot 2026-05-15 at 12 44 42" src="https://github.com/user-attachments/assets/fcf764a3-e9ed-464b-abd3-2052e03b5585" />

## Key Features

- **ExternalDNS**: Automatically updates DNS records in Route 53
- **Cert-Manager**: Provides automated SSL/TLS certificate management via Let's Encrypt
- **NGINX Ingress Controller**: Routes external traffic to services within the cluster and the service forwards to pods on port 8080
- **ArgoCD**: GitOps-based continuous deployment to update kubernetes manifests
- **Prometheus/Grafana**: Collects cluster metrics and visualises them in dashboards
- **IRSA (IAM Roles for Service Accounts)**: Uses temporary credentials via OIDC, eliminating the need for long-lived access keys


## Directory Structure

```
├── .github
│   └── workflows
│       ├── code-change-pipeline.yml
│       └── terraform-pipeline.yml
├── apps
│   └── app-hub.yaml
├── argocd
│   └── application.yaml
├── cert-man
│   └── issuer.yaml
└── terraform
│    └── modules
│        ├── ecr.tf
│        ├── eks.tf
│        ├── helm-values
│        │   ├── argocd.yaml
│        │   ├── cert-manager.yaml
│        │   ├── external-dns.yaml
│        │   └── prometheus-values.yaml
│        ├── helm.tf
│        ├── irsa.tf
│        ├── locals.tf
│        ├── providers.tf
│        ├── terraform.tfvars
│        ├── variables.tf
│        └── vpc.tf
```


## Infrastructure Components

### AWS Services

- **EKS Cluster**: Kubernetes with 3 worker nodes across 3 AZs
- **VPC**: VPC with public and private subnets
- **Route 53**: DNS management for eks.mahindevopslab.com
- **ECR**: Private container registry
- **IAM**: IRSA roles for ExternalDNS and CertManager
- **STATE MANAGEMENT**: remote state stored in S3 and statelocking enabled via Dynamodb

### Kubernetes Components

- **Application**: FastAPI devops tools (2 replicas)
- **NGINX Ingress**: LoadBalancer Service creating AWS ALB
- **ExternalDNS**: Automated DNS record management
- **CertManager**: Automated SSL certificate issuance and renewal
- **ArgoCD**: GitOps continuous deployment
- **Prometheus/Grafana**: Monitoring and observability


## CI/CD Pipeline
<img width="1920" height="1080" alt="Screenshot (448)" src="https://github.com/user-attachments/assets/fc275682-35f9-4c5b-a9dd-8b53b193e0a0" />

### GitHub Actions Workflow for changes in /app folder

1. Triggered on push to `main` branch
2. Builds Docker image with commit SHA as tag
3. Pushes image to Amazon ECR
4. Updates `k8s/deployment.yml` with new image tag
5. Commits changes back to repository
6. ArgoCD detects changes and deploys automatically


## Terraform CI/CD Workflow

- Triggers automatically when changes are pushed to the `main` branch inside the `terraform/` directory
- Checks out the latest repository code
- Configures AWS credentials securely using GitHub Secrets
- Runs a Checkov security scan to detect Terraform misconfigurations and security issues
- Initializes Terraform modules and providers using `terraform init`
- Generates an execution plan with `terraform plan`
- Deploys infrastructure changes automatically using `terraform apply`
- Uses GitHub Secrets to securely inject the Grafana admin password during deployment


## Application CI/CD Workflow

- Runs automatically after the `Terraform CICD` workflow completes successfully
- Checks out the latest repository code
- Configures AWS credentials securely using GitHub Secrets
- Logs into Amazon ECR (Elastic Container Registry)
- Pulls the Docker image from Docker Hub
- Tags the image for the target Amazon ECR repository
- Pushes the Docker image to the ECR repository
- Uses environment variables to manage AWS region, repository name, and image version
- Ensures application deployment only runs if the infrastructure deployment succeeds

**Security checks include:**

- IAM policy least privilege validation
- Encryption at rest configurations
- Network security group rules
- Public accessibility checks

### Security

- **OIDC Authentication**: GitHub Actions authenticates to AWS without long-lived credentials
- **Trivy Scans**: Docker images scanned for vulnerabilities before deployment
- **Non-root Container**: Application runs as non-root user
- **Private Subnets**: Worker nodes isolated in private subnets

 ## GitOps with ArgoCD##

<img width="1434" height="856" alt="Screenshot 2026-03-04 at 15 48 41" src="https://github.com/user-attachments/assets/cee9d1cd-a18c-4cb2-9634-6a375f8b345b" />

## Monitoring
<img width="1416" height="823" alt="Screenshot 2026-05-05 at 19 11 07" src="https://github.com/user-attachments/assets/f2aa7278-8c3b-4de0-989b-ee3aebdca557" />


### Prometheus

- Scrapes metrics from all cluster components every 15 seconds
- Monitors pod CPU, memory, network, and application metrics

### Grafana

- Visualises Prometheus data through pre-built dashboards
- Provides real-time insights into cluster health
- Accessible via port-forward: `kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80`

## DNS & SSL Automation

### ExternalDNS

- Watches Ingress resources for hostname annotations
- Creates A records in Route 53 automatically thorough IRSA access
- Updates records when LoadBalancer address changes

### CertManager

- Automatically requests SSL certificates from Let's Encrypt
- Uses DNS-01 challenge via Route 53
- Renews certificates before expiry
- Stores certificates in Kubernetes Secrets

## Deployment

### Prerequisites

- AWS CLI configured
- kubectl installed
- Terraform installed
- Helm installed

### 1. Deploy Infrastructure

```bash
cd terraform/modules
terraform init
terraform apply

```

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
Open argocd.kolz.link on browser to access ArgoCD

<img width="1025" height="58" alt="Screenshot 2026-03-04 at 14 35 21" src="https://github.com/user-attachments/assets/1de0209a-6b50-44e5-9d36-29074aed9c47" />

<img width="1440" height="857" alt="Screenshot 2026-03-04 at 14 54 20" src="https://github.com/user-attachments/assets/270bb0d4-16d5-4e8d-9458-90be488cda29" />

<img width="569" height="686" alt="Screenshot 2026-03-04 at 14 57 51" src="https://github.com/user-attachments/assets/60abca37-ed4a-406a-9158-f24d2fffd6bd" />

### 7. Login to ArgoCD
find your ArgoCD admin secrect password to Login
Run
```bash
kubectl -n argo-cd get secrets argocd-initial-admin-secret -o yaml
```
this command finds the the encrypted password from your argocd secrets
then run
```bash
echo "<encrypted password>" | base64 -d
```
This command will decrypts the password, allowing you to login to ArgoCD

<img width="1440" height="856" alt="Screenshot 2026-03-04 at 15 26 48" src="https://github.com/user-attachments/assets/580aaa15-cd97-44eb-b4ba-89dc55c9c338" />


### 8. Deploy Application on ArgoCD

Deploy your Application on Argocd by creating the following:
- **"argocd/application.yaml"**
- **"apps/app-hub.yaml"**

Then run:
```bash
kubectl apply -f argocd/application.yaml
```
This command will deploy your application on ArgoCD

<img width="1434" height="856" alt="Screenshot 2026-03-04 at 15 48 41" src="https://github.com/user-attachments/assets/467e356a-ced9-43ce-989a-71e32b3d5fd6" />

### 9. Check and Access your Application

run the following commands:
```bash
kubectl get pods -n apps
kubectl get svc -n apps
kubectl get ingress -n apps
```
These commands allow you to check if your applications pods, service and ingress are all running properly.

<img width="949" height="178" alt="Screenshot 2026-03-04 at 15 59 53" src="https://github.com/user-attachments/assets/e27631c2-0a1f-4962-a37d-0f744f9528c0" />

**Open the-app-hub.kolz.link to Access Application**

<img width="1435" height="860" alt="Screenshot 2026-03-04 at 16 04 47" src="https://github.com/user-attachments/assets/744925ab-5fdd-4dc5-aca3-1100558080b4" />


### 10. Clean up Resources

Run:
```bash
helm uninstall argocd -n argo-cd
helm uninstall cert-manager -n cert-manager
helm uninstall external-dns -n external-dns
helm uninstall nginx-ingress -n nginx-ingress
terraform destroy
```
## Future Changes
- **CI/CD Pipeline:** Automate deployment workflows using GitHub Actions.
- **Auto-Scaling:** Implement cluster auto-scaling policies.
- **Monitoring & Observability:** Integrate Prometheus, Grafana, and Loki for monitoring.
- **RBAC & Security Hardening:** Enhance security with fine-grained access control.
