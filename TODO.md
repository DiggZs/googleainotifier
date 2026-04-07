# TODO

## Google Cloud Setup
- [ ] Create GCP project and enable Google Chat API + Cloud Run API
- [ ] Create service account with `chat.bot` scope
- [ ] Add bot to target Google Chat space and record the space name (e.g. `spaces/ABC123`)

## Secrets & Config
- [ ] Add `ANTHROPIC_API_KEY` to GCP Secret Manager
- [ ] Add `CHAT_SPACE_NAME` to Cloud Run env vars
- [ ] Store service account credentials securely (never commit to repo)

## Bot Logic
- [ ] Define the actual LLM prompt in `src/llm.js` (standup, digest, alert, etc.)
- [ ] Add error handling and retries for LLM + Chat API calls
- [ ] Add structured logging (e.g. pino)

## Deployment
- [ ] Deploy to Cloud Run: `gcloud run deploy chat-bot --source . --no-allow-unauthenticated --region us-central1`
- [ ] Create Cloud Scheduler job with OIDC auth pointing at `/run-scheduled-task`

## Testing
- [ ] Write unit tests for `src/llm.js` and `src/chat.js` (mock external calls with vitest)
- [ ] Test end-to-end against a dev/test Chat space before going to production

## Optional / Future
- [ ] Add `/webhook` endpoint to handle incoming `MESSAGE` events from Google Chat
- [ ] Test locally with ngrok before deploying to Cloud Run
- [ ] Add CD step to CI (auto-deploy on merge to main via `gcloud run deploy`)
- [ ] Consider Terraform/IaC for GCP resource provisioning
- [ ] Switch from env vars to Secret Manager references in Cloud Run config
