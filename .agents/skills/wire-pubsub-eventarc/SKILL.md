---
name: wire-pubsub-eventarc
description: >
  Creates a Pub/Sub topic and wires it to a Cloud Run service using
  Eventarc triggers for GCS file upload events. Use this when the user asks
  to set up event-driven processing, async jobs, or Pub/Sub integration.
---

# Wire Pub/Sub + Eventarc to Cloud Run

## Goal
Set up an event-driven architecture where file uploads to GCS trigger
asynchronous processing on the Cloud Run service via Eventarc.

## When to use this skill
- User asks to set up event-driven processing or async jobs
- User wants GCS file uploads to trigger Cloud Run processing
- User mentions Pub/Sub, Eventarc, or event triggers

## Do not use this skill when
- User wants synchronous HTTP request/response processing
- User asks about Cloud Scheduler or cron-based triggers
- User wants to connect to non-GCS event sources (e.g., Firestore, BigQuery)

## Instructions
1. **Enable required APIs**:
   ```
   gcloud services enable eventarc.googleapis.com pubsub.googleapis.com
   ```
2. **Initialize the Eventarc service agent** (required on fresh projects):
   ```
   gcloud beta services identity create --service=eventarc.googleapis.com --project=$PROJECT_ID
   PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format='value(projectNumber)')
   gcloud projects add-iam-policy-binding $PROJECT_ID \
     --member="serviceAccount:service-${PROJECT_NUMBER}@gcp-sa-eventarc.iam.gserviceaccount.com" \
     --role="roles/eventarc.serviceAgent"
   sleep 30
   ```
3. **Create the Pub/Sub topic**:
   ```
   gcloud pubsub topics create document-processing
   ```
4. **Create a GCS bucket** for document ingestion:
   ```
   gcloud storage buckets create gs://${PROJECT_ID}-doc-intake \
     --location=us-central1
   ```
5. **Grant GCS Service Agent the Pub/Sub Publisher role**:
   ```
   STORAGE_SA=$(gcloud storage service-agent --project=$PROJECT_ID | tr -d '[:space:]')
   gcloud projects add-iam-policy-binding $PROJECT_ID \
     --member="serviceAccount:${STORAGE_SA}" \
     --role="roles/pubsub.publisher"
   ```
6. **Create an Eventarc trigger** routing GCS finalize events to Cloud Run:
   ```
   PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format='value(projectNumber)')
   gcloud eventarc triggers create doc-upload-trigger \
     --location=us-central1 \
     --destination-run-service=enterprise-api \
     --destination-run-region=us-central1 \
     --event-filters="type=google.cloud.storage.object.v1.finalized" \
     --event-filters="bucket=${PROJECT_ID}-doc-intake" \
     --service-account="${PROJECT_NUMBER}-compute@developer.gserviceaccount.com"
   ```
7. **Validate infrastructure**: Run `bash .agents/skills/wire-pubsub-eventarc/scripts/verify_pubsub.sh`
8. **Validate end-to-end**: Run `bash .agents/skills/wire-pubsub-eventarc/scripts/verify_eventarc_e2e.sh`

## Constraints
- Use Eventarc triggers, NOT direct Pub/Sub push subscriptions.
- The event type MUST be `google.cloud.storage.object.v1.finalized`.
- All commands are Cloud Shell compatible.
