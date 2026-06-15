---
name: scaffold-cloud-run-service
description: >
  Scaffolds a Python Flask microservice for Cloud Run with health checks,
  structured logging, and Buildpack support. Use this when the user asks
  to create a new service, scaffold an API, or build a Cloud Run app.
---

# Scaffold Cloud Run Service

## Goal
Generate a production-ready Python Flask microservice and deploy it to Cloud Run
using Google Cloud Buildpacks (no Dockerfile required).

## When to use this skill
- User asks to create a new service, API, or web app
- User wants to scaffold a Cloud Run project from scratch
- User mentions Flask, microservice, or health check

## Do not use this skill when
- User is modifying an existing deployed service
- User asks to deploy to GKE, App Engine, or Cloud Functions
- User already has a working Dockerfile they want to keep

## Instructions
1. **Create the application** in `app/` with these files:
   - `main.py` — Flask app with a `/health` endpoint and structured JSON logging
     via `google-cloud-logging` (use a `try/except` block to fallback to standard logging). Include a `/` and `/process` POST endpoint stub that extracts and logs Eventarc CloudEvent headers (`ce-id`, `ce-type`).
     - **Important**: Do not use `/healthz` as it is reserved by the Google Frontend.
     - **Important**: Add a global error handler that explicitly passes through `HTTPException` objects to avoid converting 404s to 500s.
   - `requirements.txt` — Flask, gunicorn, google-cloud-logging.
   - `Procfile` — `web: gunicorn --bind :$PORT main:app`
2. **CRITICAL**: Do NOT create a Dockerfile. Cloud Run Buildpacks handle containerization.
3. **CRITICAL**: Do NOT hardcode any API keys or secrets. Use `os.environ.get()` for all config.
4. **Create an Artifact Registry repository** (avoids interactive prompts during deploy):
   ```
   gcloud artifacts repositories create cloud-run-source-deploy \
     --repository-format=docker \
     --location=us-central1 \
     --description="Cloud Run Source Deploy"
   ```
5. **Deploy** using the terminal:
   ```
   cd app && gcloud run deploy enterprise-api \
     --source . \
     --region us-central1 \
     --allow-unauthenticated
   ```
6. **Validate** (must be run from the project root):
   ```
   python3 .agents/skills/scaffold-cloud-run-service/scripts/validate_scaffold.py
   ```

## Constraints
- Do NOT use Django, FastAPI, or any framework other than Flask.
- Do NOT create a Dockerfile — Buildpacks only.
- Do NOT hardcode secrets — use `os.environ.get()` for all configuration values.
- All commands must work in GCP Cloud Shell without additional installs.
