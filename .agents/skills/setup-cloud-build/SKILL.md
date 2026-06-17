---
name: setup-cloud-build
description: >
  Creates a Cloud Build pipeline for automated CI/CD deployments to
  Cloud Run. Use this when the user asks about CI/CD, automated
  deployments, or Cloud Build.
---

# Set Up Cloud Build CI/CD

## Goal
Create a Cloud Build configuration that builds and deploys the application
to Cloud Run using Buildpacks (no Dockerfile).

## When to use this skill
- User asks about CI/CD, automated deployments, or build pipelines
- User wants to set up Cloud Build for the project
- User mentions continuous integration or continuous delivery

## Do not use this skill when
- User asks about GitHub Actions, Jenkins, or non-GCP CI/CD
- User wants to deploy manually with `gcloud run deploy`
- A Cloud Build pipeline already exists for this service

## Instructions
1. **Grant IAM permissions to the Cloud Build Service Account**:
   ```
   PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format='value(projectNumber)')
   gcloud projects add-iam-policy-binding $PROJECT_ID \
     --member="serviceAccount:${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com" \
     --role="roles/run.admin"
   gcloud projects add-iam-policy-binding $PROJECT_ID \
     --member="serviceAccount:${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com" \
     --role="roles/iam.serviceAccountUser"
   ```
2. **Read the golden template** at `references/cloudbuild.yaml.tmpl`.
3. **Generate** `infra/cloudbuild.yaml` based on the template, customized
   with the user's project region and service name.
4. **Verify the generated file exists**:
   ```
   cat infra/cloudbuild.yaml
   ```

## Constraints
- Use the template in `references/`, do NOT generate cloudbuild.yaml from scratch.
- The build MUST use Buildpacks (`gcloud run deploy --source`), no Dockerfile step.
- Do NOT run `gcloud builds submit`. Only generate the YAML file and verify it.
