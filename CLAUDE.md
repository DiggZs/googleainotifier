# CLAUDE.md — GoogleAINotifier

A scheduled Google Chat bot that calls Claude (Anthropic) on a cron schedule and posts AI-generated messages to a Google Chat space. Hosted on Cloud Run, triggered by Cloud Scheduler, infrastructure managed with Terraform.

---

## Stack

| Layer | Tool |
|---|---|
| Runtime | Node.js 22, ESM (`"type": "module"`) |
| Framework | Express (Cloud Run HTTP server) |
| LLM | Google Gemini via `@google-cloud/vertexai` (Vertex AI) |
| Chat API | Google Chat REST API via `google-auth-library` |
| Container | Docker → Google Artifact Registry |
| Infra | Terraform → Cloud Run, Cloud Scheduler, Secret Manager |
| CI | GitHub Actions (`ci.yml`) — lint + test on PRs |
| CD | GitHub Actions (`cd.yml`) — build image + terraform apply on main |
| Auth (GH→GCP) | Workload Identity Federation (OIDC, keyless — no stored keys) |

---

## Directory Structure

```
.
├── src/
│   ├── index.js        # Express entry point — POST /run-scheduled-task, GET /health
│   ├── llm.js          # Anthropic wrapper — generateMessage()
│   └── chat.js         # Google Chat helper — postToChat(text)
├── terraform/
│   ├── providers.tf    # Google provider, GCS backend config
│   ├── variables.tf    # All input variables
│   ├── outputs.tf      # Cloud Run URL, WIF provider name, deployer SA email
│   ├── apis.tf         # Enable required GCP APIs
│   ├── iam.tf          # Service accounts, Workload Identity Federation, IAM bindings
│   ├── artifact.tf     # Artifact Registry repository
│   ├── secrets.tf      # Secret Manager secret for ANTHROPIC_API_KEY
│   ├── cloudrun.tf     # Cloud Run v2 service
│   └── scheduler.tf    # Cloud Scheduler job
├── .github/workflows/
│   ├── ci.yml          # Lint + test on PRs and feature branch pushes
│   └── cd.yml          # Build image + terraform apply on push to main
├── Dockerfile
├── .env.example
└── TODO.md
```

---

## Local Development

```bash
# Install dependencies
npm install

# Copy and fill in env vars
cp .env.example .env

# Run locally (needs ANTHROPIC_API_KEY and CHAT_SPACE_NAME in .env)
npm run dev

# Trigger the scheduled task manually
curl -X POST http://localhost:8080/run-scheduled-task

# Health check
curl http://localhost:8080/health
```

---

## Commands

```bash
npm run start     # production start
npm run dev       # node --watch (auto-restart)
npm run test      # vitest run
npm run lint      # eslint src/
```

---

## Environment Variables

| Variable | Required | Description |
|---|---|---|
| `GOOGLE_CLOUD_PROJECT` | Yes | GCP project ID — used by Vertex AI SDK to route requests |
| `CHAT_SPACE_NAME` | Yes | Google Chat space, e.g. `spaces/ABC123` |
| `PORT` | No | HTTP port (default: 8080) |
| `GOOGLE_APPLICATION_CREDENTIALS` | Local dev only | Path to service account key file; not used in Cloud Run (ADC handles it) |

---

## GitHub Secrets Required

Secrets are scoped to **GitHub Environments** (`development` and `production`) so each environment can target a different GCP project.

| Secret | Environment | Value |
|---|---|---|
| `GCP_WIF_PROVIDER` | both | `terraform output wif_provider` after bootstrap |
| `GCP_SERVICE_ACCOUNT` | both | `terraform output deployer_service_account` after bootstrap |

> `project_id`, `chat_space_name`, and `region` now live in `terraform/environments/dev.tfvars` and `prod.tfvars` — not in GitHub Secrets. No API key secrets needed; Gemini auth is handled by the bot's service account via ADC.

---

## Bootstrap (One-Time Setup)

These steps are done once manually before the CD pipeline can run autonomously.

### 1. Create GCS buckets for Terraform state

```bash
# Dev
gcloud storage buckets create gs://c3b-ainotifier-dev \
  --project=YOUR_DEV_PROJECT_ID --location=US

# Prod
gcloud storage buckets create gs://c3b-ainotifier-prod \
  --project=YOUR_PROD_PROJECT_ID --location=US
```

### 2. Fill in the environment tfvars files

Edit `terraform/environments/dev.tfvars` and `prod.tfvars` with real values for `project_id`, `chat_space_name`, etc.

### 3. Run Terraform bootstrap (repeat for each environment)

```bash
cd terraform

# Dev
terraform init \
  -backend-config="bucket=c3b-ainotifier-dev" \
  -backend-config="prefix=terraform"
terraform apply \
  -var-file="environments/dev.tfvars" \
  -var="image_url=us-central1-docker.pkg.dev/YOUR_DEV_PROJECT/google-ai-notifier/google-ai-notifier:bootstrap" \
  -var="github_repo=YOUR_ORG/YOUR_REPO"

# Prod (re-init to switch backend)
terraform init -reconfigure \
  -backend-config="bucket=c3b-ainotifier-prod" \
  -backend-config="prefix=terraform"
terraform apply \
  -var-file="environments/prod.tfvars" \
  -var="image_url=us-central1-docker.pkg.dev/YOUR_PROD_PROJECT/google-ai-notifier/google-ai-notifier:bootstrap" \
  -var="github_repo=YOUR_ORG/YOUR_REPO"
```

> `image_url` is a placeholder on bootstrap — Cloud Run won't receive traffic until Cloud Scheduler fires.

### 4. Set GitHub Environment Secrets

In GitHub: **Settings → Environments** → create `development` and `production`, then add to each:

```bash
# Get outputs per environment (run after each terraform apply above)
terraform output wif_provider              # → GCP_WIF_PROVIDER
terraform output deployer_service_account  # → GCP_SERVICE_ACCOUNT
```

### 5. Add the bot to your Chat space

In Google Chat, add the bot service account email to the target space. Get the space name from the Chat URL.

---

## Key Implementation Notes

- **Ingress**: Cloud Run is set to `INGRESS_TRAFFIC_INTERNAL_ONLY` — only Cloud Scheduler (via OIDC) can invoke it. No public access.
- **Auth flow**: Cloud Scheduler uses OIDC with its own service account to call Cloud Run.
- **Image tagging**: CD pipeline tags images with both `git-sha` (immutable) and `latest`. Terraform deploys using the SHA digest from the build step for determinism.
- **WIF**: GitHub Actions authenticates to GCP with Workload Identity Federation — no service account keys are stored in GitHub.
- **LLM prompt**: Edit `src/llm.js` to change what the bot generates. The TODO comment marks where the prompt lives.
- **Scaling**: Cloud Run is configured `min=0, max=1` — it scales to zero when not running.

---

## Bot Logic

Edit `src/llm.js` to change the prompt sent to Claude. The bot currently sends a placeholder prompt. Replace the `content` field with whatever you want the bot to generate — standup summaries, digests, alerts, etc.

---

## Adding Tests

Tests go in `src/__tests__/`. Use `vi.mock()` in vitest to mock `@anthropic-ai/sdk` and `google-auth-library` so tests don't make real API calls.

Example:
```js
// src/__tests__/llm.test.js
import { describe, it, expect, vi } from 'vitest';

vi.mock('@anthropic-ai/sdk', () => ({
  default: vi.fn().mockImplementation(() => ({
    messages: {
      create: vi.fn().mockResolvedValue({
        content: [{ text: 'hello from claude' }]
      })
    }
  }))
}));

import { generateMessage } from '../llm.js';

describe('generateMessage', () => {
  it('returns text from LLM response', async () => {
    const result = await generateMessage();
    expect(result).toBe('hello from claude');
  });
});
```
