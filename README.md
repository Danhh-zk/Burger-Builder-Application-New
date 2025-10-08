# Team5 Burger Builder DevOps

This repository contains everything you need to **provision**, **configure**, **deploy**, and **validate** the **Burger Builder Application** on Azure.  

---

## 🧰 Prerequisites

### Tooling
- [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli) `>= 2.52`
- [Terraform](https://developer.hashicorp.com/terraform/downloads) `>= 1.6`
- Docker, Node 20+, and Java 21 / Maven (optional for local builds)

### Azure Access
- Active **Azure subscription** with:
  - **Contributor** access for creating resources
  - **Owner** access if role assignments or new Action Groups are needed
- **Service Principal credentials** stored as GitHub secret → `AZURE_CREDENTIALS`
- Existing remote Terraform backend (e.g., `tfstate-rg` → `tfstate-container`)

### Budgets & Quotas
- Confirm region (*EastUS2*) for:
  - App Service Plan **P1v2**
  - Application Gateway **Standard_v2**
  - Azure SQL **S0 tier**
- Ensure outbound access to Docker Hub for image pulls

---

## ☁️ How to Provision (Terraform)

1. **Log in and select the subscription**
   ```bash
   az login
   az account set --subscription "<subscription-id>"

2. **Prepare secrets**
   export TF_VAR_sql_admin_password="StrongP@ssword123!"
   
4. **Init, plan, and apply**
   ```bash
   cd terraform/

   terraform init
   terraform plan -out plan
   terraform apply -auto-approve plan
   ```
4. **Review outputs**
   ```bash
   terraform output
   ```
   Outputs:
   - `app_gateway_public_ip`
     
Re-run `terraform apply` whenever infrastructure changes are committed. The remote backend keeps state consistent across machines and CI.


## How to Deploy (GitHub Actions)

Three workflows under `.github/workflows/`:

| Workflow       | Trigger                  | Purpose                                              | Required Secrets                          |
| -------------- | ------------------------ | ---------------------------------------------------- | ----------------------------------------- |
| `infra.yml`    | Push to `main` or manual | Runs Terraform to provision infrastructure           | `AZURE_CREDENTIALS`, `SQL_ADMIN_PASSWORD` |
| `backend.yml`  | Push to `main` or manual | Builds & pushes backend image to Docker Hub          | `DOCKERHUB_USERNAME`, `DOCKERHUB_TOKEN`   |
| `frontend.yml` | Push to `main` or manual | Builds & pushes frontend image (injects backend URL) | `DOCKERHUB_USERNAME`, `DOCKERHUB_TOKEN`   |


## How to Validate (Private Environment)

Because both apps are private, validation must be performed from inside the Azure VNet (for example, Application Gateway).

### 1. Validate via Application Gateway

If WAF/Application Gateway is enabled:

 -Access through the App Gateway public IP (found in Terraform outputs)

 -Confirm:

     -The frontend renders successfully
     -Backend requests are routed through the gateway
     -HTTP redirection works correctly
     
### 2.Frontend and Backend Test

Open the Application Gateway public IP in your browser:
        
    https://<app-gateway-public-ip>/

### 5. Postman
Inside the VNet, use the private FQDNs:   
      
    GET /api/health
    POST /api/order


Developed by Team5
Frontend → React + TypeScript + Vite | Backend → Maven-Java REST API | Database → Azure SQL
🚀 Powered by Terraform and GitHub Actions.

