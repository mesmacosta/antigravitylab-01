#!/bin/bash
# Verifies Pub/Sub topic and Eventarc trigger exist.
set -euo pipefail

PROJECT_ID=${PROJECT_ID:-$(gcloud config get-value project 2>/dev/null)}
echo "🔍 Checking Pub/Sub topic..."
if gcloud pubsub topics describe document-processing > /dev/null 2>&1; then
  echo "✅ Pub/Sub topic 'document-processing' exists."
else
  echo "❌ Pub/Sub topic 'document-processing' NOT found."
  exit 1
fi

echo "🔍 Checking GCS bucket..."
if gcloud storage buckets describe gs://${PROJECT_ID}-doc-intake > /dev/null 2>&1; then
  echo "✅ GCS bucket '${PROJECT_ID}-doc-intake' exists."
else
  echo "❌ GCS bucket NOT found."
  exit 1
fi

echo "🔍 Checking Eventarc trigger..."
if gcloud eventarc triggers describe doc-upload-trigger --location=us-central1 > /dev/null 2>&1; then
  echo "✅ Eventarc trigger 'doc-upload-trigger' exists."
else
  echo "❌ Eventarc trigger NOT found."
  exit 1
fi

echo "✅ Pub/Sub + Eventarc verification complete."
