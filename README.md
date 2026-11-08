# Azure App Service with Terraform

This repository provisions a Linux Azure App Service Plan and Web App in separate `dev` and `uat` resource groups. The shared module is in `modules/app-service`. Both environment roots configure the `azurerm` remote backend and store state in an Azure Storage container, with a separate state blob key for each environment. Only the one-time `bootstrap-state` configuration uses local state.

## Prerequisites

- Terraform 1.6 or later and Azure CLI.
- An Azure subscription and a principal allowed to create resource groups, App Service Plans, and Web Apps.
- Separate Azure service principals for dev and UAT, each with a client ID and client secret.
- For remote state, the GitHub Actions identity needs **Storage Blob Data Contributor** on the state storage account/container, in addition to resource deployment permissions.

## Create the remote state storage

The current environment backend is configured directly in each environment's `main.tf` to use resource group `tfstateRG01`, storage account `tfstate01965229201`, and private container `tfstate`. The bootstrap configuration below is an optional way to create a different state account for a fresh setup; it is not needed for the account already configured here.

```powershell
az login
az account set --subscription <subscription-id>
terraform -chdir=bootstrap-state init
terraform -chdir=bootstrap-state apply
terraform -chdir=bootstrap-state output
```

The bootstrap uses local Terraform state in `bootstrap-state/terraform.tfstate`; keep that file secure and backed up. The resulting storage account has public blob access disabled, shared key access disabled, and a private `tfstate` container. If you use this optional bootstrap for a new state account, update both environment backend blocks with its output values and grant both service principals Storage Blob Data Contributor on that account.

Create GitHub Environments named `app-service-dev` and `app-service-uat`. In each environment, add secrets with these names, using that environment's own service principal credentials:

- `AZURE_CLIENT_ID`
- `AZURE_CLIENT_SECRET`
- `AZURE_TENANT_ID`
- `AZURE_SUBSCRIPTION_ID`

Grant both service principals permission to deploy App Service resources and **Storage Blob Data Contributor** on the configured state storage account. Configure GitHub environment protection rules on `app-service-uat` to gate the UAT job.

Each environment's `main.tf` fixes the remote resource group, storage account, container name (`tfstate`), and its own state key (`dev.tfstate` or `uat.tfstate`), so `terraform init` will not prompt for backend values. After `az login` and selecting the subscription, run:

```powershell
terraform -chdir=environments/dev init
terraform -chdir=environments/dev plan
terraform -chdir=environments/dev apply
```

Repeat with `terraform -chdir=environments/uat init` for UAT. Do not commit state files, plan files, or secrets.

## Environment configuration

Edit `terraform.tfvars` in each environment before deploying. `name_prefix` must be globally unique enough for Azure's Web App hostname namespace; replace the `myapp-change-me` sample. Choose an appropriate App Service Plan SKU for your workload. The defaults use Central India and B1.

Put non-secret settings in `app_settings`. Do not place credentials or other secrets in Terraform variables or state; use Key Vault references or inject secrets through a protected deployment mechanism.

## GitHub Actions pipeline

The GitHub Actions workflow is `.github/workflows/terraform-deploy.yml`. Pull requests run formatting and validation. Changes to `main` provision dev, verify that the App Service reaches `Running`, then plan and apply UAT. The optional `deploy_app` input on a manually dispatched run deploys `app.zip` from the repository root to both environments. This repository has no application source or build command, so add a build/package step before enabling app deployment.

## Layout

```text
bootstrap-state/             One-time remote state storage setup (local bootstrap state)
modules/app-service/          Reusable Linux App Service module
environments/dev/             Dev root module and backend example
environments/uat/             UAT root module and backend example
.github/workflows/            GitHub Actions workflow
```
