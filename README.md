# EKS Cluster App Hub Deployment

## Overview
This project is a production-grade application hub deployment on AWS EKS. The deployment spans three availability zones for high availability and uses EKS Managed Node Groups for scalability. Infrastructure is automated using Terraform, and the application is containerised using Docker and stored in Amazon ECR.
<img width="1434" height="869" alt="Screenshot 2026-05-15 at 15 14 13" src="https://github.com/user-attachments/assets/a209b623-be3b-4136-88eb-aeb57d74d07a" />

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
<img width="1434" height="467" alt="Screenshot 2026-05-15 at 15 16 29" src="https://github.com/user-attachments/assets/b71f215c-86de-4c8b-b685-898f652a5309" />
<img width="1439" height="459" alt="Screenshot 2026-05-15 at 15 17 08" src="https://github.com/user-attachments/assets/4f4c18dd-3bd9-481b-92bf-3975c53011aa" />



## Terraform CI/CD Workflow

- Triggers automatically when changes are pushed to the `main` branch inside the `terraform/` directory
- Checks out the latest repository code
- Configures AWS credentials securely using GitHub Secrets
- Runs a Checkov security scan to detect Terraform misconfigurations and security issues
- Initializes Terraform modules and providers using `terraform init`
- Generates an execution plan with `terraform plan`
- Deploys infrastructure changes automatically using `terraform apply`
- Uses GitHub Secrets to securely inject the Grafana admin password during deployment


## Docker Build and Deploy CI/CD Workflow

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

<img width="1440" height="857" alt="Screenshot 2026-03-04 at 14 54 20" src="https://github.com/user-attachments/assets/9b7152a5-634e-404e-b745-4e3f3549e637" />

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
### 2. Configure kubectl
```bash
aws eks --region <region> update-kubeconfig --name <cluster-name>
```
### 3. Configure Cert Manager ClusterIssuer

Apply the Kubernetes `ClusterIssuer` configuration to enable automatic SSL/TLS certificate management with Cert Manager.

```bash
kubectl apply -f clusterissuer.yml

```

### 4.Search for argocd host domain
Then run:
 ```bash
kubectl get ingress -A
```
<img width="1015" height="30" alt="Screenshot 2026-05-15 at 14 57 10" src="https://github.com/user-attachments/assets/803f912c-e660-40ed-a5d8-cd32ff4c5abb" />


### 5. Login to ArgoCD
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

### 6. Deploy Application with Argo CD

Apply the Argo CD `Application` manifest to deploy and manage the application from the GitHub repository using GitOps.

```bash
kubectl apply -f argocd/application.yaml
```

This configuration:
- Connects Argo CD to the GitHub repository
- Deploys resources from the `apps/` directory
- Automatically creates the target namespace if it does not exist
- Continuously monitors the repository for changes
- Automatically syncs and applies updates to the Kubernetes cluster
- Removes outdated Kubernetes resources (`prune`)
- Restores resources if manual changes are detected (`selfHeal`)

<img width="1434" height="856" alt="Screenshot 2026-03-04 at 15 48 41" src="https://github.com/user-attachments/assets/467e356a-ced9-43ce-989a-71e32b3d5fd6" />

### 9. Check and Access your Application

run the following commands:
```bash
kubectl get pods -n apps
kubectl get svc -n apps
kubectl get ingress -n apps
```
These commands allow you to check if your applications pods, service and ingress are all running properly.

<img width="959" height="303" alt="Screenshot 2026-05-15 at 15 08 41" src="https://github.com/user-attachments/assets/98b2d689-cbf0-4763-8a3a-cc6590725c25" />


**Open eks.kolz.link to Access Application**

<img width="1434" height="869" alt="Screenshot 2026-05-15 at 15 14 13" src="https://github.com/user-attachments/assets/33d57907-75f0-4a85-9603-f6689f1fdf38" />



### 10. Clean up Resources

Run:
```bash
helm uninstall argocd -n argo-cd
helm uninstall cert-manager -n cert-manager
helm uninstall external-dns -n external-dns
helm uninstall nginx-ingress -n nginx-ingress
terraform destroy
```
## What I Learnt

### IRSA (IAM Roles for Service Accounts)

Understanding how Kubernetes ServiceAccounts can assume AWS IAM roles using OIDC was crucial. The trust policy conditions (`:sub` and `:aud`) must exactly match the ServiceAccount namespace and name, and pods must be restarted after annotation changes for environment variables to be injected.

### DNS-01 Challenge

CertManager uses DNS-01 challenge for wildcard certificates and when HTTP-01 isn't feasible. It creates TXT records in Route 53 that Let's Encrypt verifies before issuing certificates. This requires Route 53 permissions via IRSA.

### GitOps Benefits

Having Git as the single source of truth eliminates configuration drift. Any manual changes to the cluster are automatically reverted by ArgoCD, ensuring consistency and auditability.

## Future Improvements

- Implement Horizontal Pod Autoscaler (HPA)
- Add Vertical Pod Autoscaler (VPA)
- Configure AlertManager for Prometheus alerts
- Implement network policies for pod-to-pod communication
- Add Velero for cluster backups
