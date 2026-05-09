---
name: inject-secrets
description: >
  Creates secrets in Google Cloud Secret Manager and binds them to a
  Cloud Run service as environment variables. Use this when the user asks
  to secure API keys, inject secrets, or configure Secret Manager.
---

# Inject Secrets into Cloud Run

## Goal
Store sensitive configuration in Secret Manager and mount it into Cloud Run
as environment variables — zero hardcoded credentials.

## When to use this skill
- User asks to secure API keys, passwords, or tokens
- User wants to inject secrets into a Cloud Run service
- User mentions Secret Manager or credential management

## Do not use this skill when
- User is working with non-sensitive configuration (use env vars directly)
- User asks about Vault, AWS Secrets Manager, or non-GCP secret stores
- Secrets already exist and are mounted on the service

## Instructions
1. **Create the secret** (uses a placeholder value for the lab):
   ```
   printf "PLACEHOLDER_KEY_FOR_LAB" | gcloud secrets create gemini-api-key \
     --data-file=- \
     --replication-policy=automatic
   ```
2. **Grant Cloud Run's service account access**:
   ```
   PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format='value(projectNumber)')
   gcloud secrets add-iam-policy-binding gemini-api-key \
     --member="serviceAccount:${PROJECT_NUMBER}-compute@developer.gserviceaccount.com" \
     --role="roles/secretmanager.secretAccessor"
   ```
3. **Update the Cloud Run service** to mount the secret:
   ```
   gcloud run services update enterprise-api \
     --region us-central1 \
     --set-secrets=GEMINI_API_KEY=gemini-api-key:latest
   ```
4. **Validate**: Run `bash .agents/skills/inject-secrets/scripts/verify_secrets.sh`

## Constraints
- NEVER echo or print secret values to the terminal output.
- NEVER hardcode secret values in any source file.
- All commands are Cloud Shell compatible (gcloud, printf).

## Approval Gate
- HALT before running `gcloud secrets create`. Ask the user to confirm.
