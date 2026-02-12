# Azure DevOps Pipeline Setup Guide

Step-by-step guide to configure CI/CD pipelines for QuckApp at `https://dev.azure.com/AtomiverX/QuckApp`.

## Prerequisites

- Azure DevOps organization: **AtomiverX**
- Azure DevOps project: **QuckApp**
- Azure Container Registry (ACR): `quckapp.azurecr.io`
- AKS clusters provisioned for each environment
- GitHub repository connected to Azure DevOps

---

## 1. Service Connections

Create these service connections under **Project Settings > Service connections**.

### 1.1 GitHub Service Connection

1. Click **New service connection** > **GitHub**
2. Authentication: OAuth or PAT
3. Name: `GitHubServiceConnection`
4. Grant access to all pipelines

### 1.2 ACR Service Connection

1. Click **New service connection** > **Docker Registry**
2. Select **Azure Container Registry**
3. Choose subscription and ACR (`quckapp.azurecr.io`)
4. Name: `QuckApp-ACR`
5. Grant access to all pipelines

### 1.3 Azure Subscription Connections

Create one per environment tier:

| Connection Name | Purpose |
|---|---|
| `QuckApp-Dev` | Dev + QA deployments |
| `QuckApp-UAT` | UAT1, UAT2, UAT3 deployments |
| `QuckApp-Staging` | Staging deployments |
| `QuckApp-Production` | Production deployments |

### 1.4 AKS Service Connections

1. Click **New service connection** > **Kubernetes**
2. Authentication: Azure Subscription (recommended for AKS)
3. Select AKS cluster
4. Create one per cluster:

| Connection Name | AKS Cluster | Environments |
|---|---|---|
| `quckapp-aks-dev` | `aks-dev` | dev |
| `quckapp-aks-qa` | `aks-qa` | qa |
| `quckapp-aks-uat` | `aks-uat` | uat1, uat2, uat3 |
| `quckapp-aks-staging` | `aks-staging` | staging |
| `quckapp-aks-prod` | `aks-prod` | live |

---

## 2. Variable Groups

Create variable groups under **Pipelines > Library > + Variable group**.

### 2.1 Required Variable Groups

Refer to `variable-groups.yml` for the full list. At minimum, create:

**Global:**
- `QuckApp-Global-Variables` — ACR registry, Key Vault name, App Insights key

**CI/CD Build:**
- `quckapp-ci-common` — ACR login server, service connection name, build defaults
- `quckapp-ci-springboot` — Java/Maven versions
- `quckapp-ci-nestjs` — Node/npm versions
- `quckapp-ci-go` — Go version, CGO settings
- `quckapp-ci-elixir` — Elixir/OTP versions
- `quckapp-ci-python` — Python version

**Per-Environment:**
- `QuckApp-Local-Variables`
- `QuckApp-Variables` (dev)
- `QuckApp-QA-Variables`
- `QuckApp-UAT1-Variables`
- `QuckApp-UAT2-Variables`
- `QuckApp-UAT3-Variables`
- `QuckApp-Staging-Variables`
- `QuckApp-Live-Variables`

### 2.2 Linking Azure Key Vault

For sensitive values (passwords, keys, tokens):

1. Edit variable group
2. Toggle **Link secrets from an Azure key vault as variables**
3. Select Azure subscription and Key Vault (`kv-quckapp`)
4. Add required secrets (e.g., `DEV-JWT-SECRET`, `PROD-MONGODB-URI`)

---

## 3. Pipeline Creation

### 3.1 CI Pipeline (auto-discovered)

The root `azure-pipelines.yml` is auto-discovered by Azure DevOps:

1. Go to **Pipelines > New pipeline**
2. Select **GitHub** as the source
3. Select the QuckApp repository
4. Azure DevOps will auto-detect `azure-pipelines.yml`
5. Click **Run** to verify

This pipeline:
- Triggers on pushes to `main`
- Detects changed services via `git diff`
- Runs lint + test per stack in parallel
- Builds + pushes Docker images to ACR

### 3.2 PR Validation Pipeline

1. Go to **Pipelines > New pipeline**
2. Select **GitHub** > QuckApp repository
3. Choose **Existing Azure Pipelines YAML file**
4. Path: `infrastructure/azure-pipelines/pr-validation.yml`
5. Name it: `QuckApp PR Validation`

### 3.3 CD Pipeline (existing)

The existing `cd-main.yml` handles deployments. It's triggered by:
- CI pipeline completion (via webhook)
- Manual trigger with service name + image tag

---

## 4. Branch Policies

Configure branch policies for the `main` branch:

1. Go to **Repos > Branches > main > Branch policies**
2. Enable:
   - **Require a minimum number of reviewers**: 1
   - **Check for linked work items**: Optional
   - **Check for comment resolution**: Required
3. Under **Build validation**, add:
   - Pipeline: `QuckApp PR Validation`
   - Trigger: Automatic
   - Policy requirement: Required
   - Build expiration: After 12 hours

---

## 5. Environments

Create deployment environments under **Pipelines > Environments**:

| Environment | Approvers | Approvals |
|---|---|---|
| `quckapp-local-mock` | None | Auto |
| `quckapp` (dev) | None | Auto |
| `quckapp-qa` | QA Lead | 1 |
| `quckapp-uat1` | Product Owner | 1 |
| `quckapp-uat2` | Product Owner | 1 |
| `quckapp-uat3` | Product Owner + Security | 2 |
| `quckapp-staging` | Release Manager | 1 |
| `quckapp-production` | CAB + Release Manager + CTO | 3 |

For each environment:
1. Click **New environment**
2. Name it per the table above
3. Under **Approvals and checks**:
   - Add **Approvals** with the required approvers
   - Add **Business hours** check for production (optional)

---

## 6. Pipeline Flow

```
Push to main
    |
    v
CI Pipeline (azure-pipelines.yml)
    |
    ├── Detect Changes
    |       |
    |       ├── Test NestJS ──┐
    |       ├── Test Spring ──┤
    |       ├── Test Go ──────┤  (parallel)
    |       ├── Test Elixir ──┤
    |       └── Test Python ──┘
    |               |
    |               v
    |       Build Docker Images
    |       Push to ACR
    |
    v
CD Pipeline (cd-main.yml) — triggered by CI
    |
    ├── Local/Mock ──> Dev ──> QA ──> UAT1 ──> UAT2 ──> UAT3 ──> Staging ──> Live
    |     (auto)      (auto)  (QA)   (PO)     (PO)    (PO+Sec) (RM)       (CAB)
```

```
Pull Request to main
    |
    v
PR Validation Pipeline (pr-validation.yml)
    |
    ├── Detect Changes
    |       |
    |       ├── Validate NestJS ──┐
    |       ├── Validate Spring ──┤
    |       ├── Validate Go ──────┤  (parallel, only changed stacks)
    |       ├── Validate Elixir ──┤
    |       ├── Validate Python ──┤
    |       └── Validate Helm ────┘
    |
    └── PR Summary
```

---

## 7. Troubleshooting

### Pipeline not auto-discovered
- Ensure `azure-pipelines.yml` is at the repository root
- Check that the GitHub service connection has access to the repository

### Submodule checkout fails
- Verify `checkout: self` with `submodules: true` is in the pipeline
- Ensure the GitHub PAT has access to all submodule repositories

### ACR push fails
- Verify the `QuckApp-ACR` service connection is configured
- Check that the `ACR_LOGIN_SERVER` variable is set in `quckapp-ci-common`

### Tests fail for a specific stack
- Check the validate-step.yml template for the correct tool versions
- Ensure service dependencies (e.g., `go.mod replace` directives) are satisfied

### Helm validation fails
- Install Helm 3.x on the build agent
- Ensure Chart.yaml exists in each Helm chart directory
