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
2. **Create the Pub/Sub topic**:
   ```
   gcloud pubsub topics create document-processing
   ```
3. **Create a GCS bucket** for document ingestion:
   ```
   gcloud storage buckets create gs://${PROJECT_ID}-doc-intake \
     --location=us-central1
   ```
4. **Grant GCS Service Agent the Pub/Sub Publisher role**:
   ```
   STORAGE_SA="$(gcloud storage service-agent --project=$PROJECT_ID)"
   gcloud projects add-iam-policy-binding $PROJECT_ID \
     --member="serviceAccount:${STORAGE_SA}" \
     --role="roles/pubsub.publisher"
   ```
5. **Create an Eventarc trigger** routing GCS finalize events to Cloud Run:
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
6. **Validate**: Run `bash scripts/verify_pubsub.sh`

## Constraints
- Use Eventarc triggers, NOT direct Pub/Sub push subscriptions.
- The event type MUST be `google.cloud.storage.object.v1.finalized`.
- All commands are Cloud Shell compatible.
