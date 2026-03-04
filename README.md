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
