# Azure App Service with Terraform

This repository provisions a resilient Linux Azure App Service in separate `dev` and `uat` resource groups. Each environment has a Central India primary, a South India standby, an App Service staging slot in each region, and Azure Traffic Manager for priority-based regional failover. Both environment roots store Terraform state remotely in Azure Storage with a separate blob key. Only the optional one-time state-account bootstrap uses local state.

## Prerequisites

- Terraform 1.6 or later and Azure CLI.
- An Azure subscription and a principal allowed to create resource groups, App Service Plans, and Web Apps.
- Separate Azure service principals for dev and UAT, each with a client ID and client secret.
- Each GitHub environment service principal needs **Storage Blob Data Contributor** on the state storage account, plus resource deployment permissions.

## Create the remote state storage

The current environment backends are configured directly in each environment's `main.tf` to use resource group `tfstateRG01`, storage account `tfstate01965229201`, and container `tfstate`. The bootstrap configuration below is optional for a fresh setup; it is not needed for the account already configured here.

```powershell
az login
az account set --subscription <subscription-id>
terraform -chdir=bootstrap-state init
terraform -chdir=bootstrap-state apply
terraform -chdir=bootstrap-state output
```

The bootstrap uses local Terraform state in `bootstrap-state/terraform.tfstate`; keep that file secure and backed up. The resulting storage account has GRS redundancy, public blob access disabled, shared key access disabled, and a private `tfstate` container. If you use this optional bootstrap for a new state account, update both environment backend blocks with its output values and grant both service principals Storage Blob Data Contributor on that account. The existing state account configured above is external and its current redundancy setting is not changed by this code.

Create GitHub Environments named `app-service-dev` and `app-service-uat`. In each environment, add secrets with these names, using that environment's own service principal credentials:

- `AZURE_CLIENT_ID`
- `AZURE_CLIENT_SECRET`
- `AZURE_TENANT_ID`
- `AZURE_SUBSCRIPTION_ID`

Grant both service principals permission to deploy App Service resources and **Storage Blob Data Contributor** on the configured state storage account. Configure GitHub environment protection rules on `app-service-uat` to gate the UAT job.

Each environment's `main.tf` fixes the remote resource group, account, container (`tfstate`), and state key (`dev.tfstate` or `uat.tfstate`), so `terraform init` will not prompt for backend values. After `az login` and selecting the subscription, run:

```powershell
terraform -chdir=environments/dev init
terraform -chdir=environments/dev plan
terraform -chdir=environments/dev apply
```

Repeat with `terraform -chdir=environments/uat init` for UAT. Do not commit state files, plan files, or secrets.

## Environment configuration

Edit `terraform.tfvars` in each environment before deploying. `name_prefix` must be globally unique for the Web App and Traffic Manager DNS names; replace the `myapp-change-me` sample. The default primary/secondary regions are Central India and its paired region, South India. The default App Service Plan SKU is S1 because deployment slots require Standard tier or higher.

Put non-secret settings in `app_settings`. Do not place credentials or other secrets in Terraform variables or state; use Key Vault references or inject secrets through a protected deployment mechanism.

## Blue-green deployment and disaster recovery

Each regional Web App has a `staging` slot. On a manually dispatched GitHub Actions run with `deploy_app` enabled, the workflow deploys `app.zip` to both staging slots, checks the configured health endpoint, and swaps the slots into production. The previous production build remains in the staging slot after a swap, allowing a swap-back rollback. Use backward-compatible database migrations and keep environment-specific app settings in the configured sticky settings for genuinely zero-downtime releases.

Azure Traffic Manager uses HTTPS health probes and priority routing to return the Central India primary while healthy, then South India after the primary fails its probes. The health path defaults to `/health`; the application must implement that path and return HTTP 200. Set `health_check_path` in the environment variables/tfvars to the app's real readiness endpoint before deployment. Traffic Manager is DNS-based: resolver/client caching can delay failover beyond its configured 30-second DNS TTL and probe intervals, so regional recovery is not instant and cannot guarantee zero downtime.

Traffic Manager does not proxy requests or terminate TLS. Its `*.trafficmanager.net` name is not covered by the App Service default certificates. For production HTTPS through the failover name, configure a domain you own, point its DNS record to the Traffic Manager FQDN, and bind a valid TLS certificate for that domain to both regional App Services. The Terraform output is therefore named `traffic_manager_fqdn`, not `app_url`.

This adds two App Service plans per environment (four S1 plans across dev and UAT) and a Traffic Manager profile per environment. Expect materially higher Azure charges than the original single B1 plan. The DR configuration covers the web tier only: databases, queues, file/blob data, identity dependencies, and backup/restore plans must also be replicated or recoverable in the secondary region. The existing Terraform state storage account is external to this module; configure its redundancy separately if state recovery across a regional outage is required.

## GitHub Actions pipeline

The GitHub Actions workflow is `.github/workflows/terraform-deploy.yml`. Pull requests to `main` or `develop` run formatting and validation. Pushes to either branch provision dev, verify both regional apps are running, then plan and apply UAT. Configure GitHub environment protection rules on `app-service-uat` to approve the UAT job. The optional `deploy_app` input on a manually dispatched run requires `app.zip` at the repository root; this repository has no application source/build command, so add a packaging step before enabling it.

## Layout

```text
bootstrap-state/             Optional one-time remote state storage setup (local bootstrap state)
modules/app-service/          Reusable Linux App Service module
environments/dev/             Dev root module and remote backend
environments/uat/             UAT root module and remote backend
.github/workflows/            GitHub Actions workflow
```
