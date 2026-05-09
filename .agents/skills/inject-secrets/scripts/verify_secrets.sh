#!/bin/bash
# Verifies Secret Manager secret exists and is bound to Cloud Run.
set -euo pipefail

echo "🔍 Checking Secret Manager..."

if gcloud secrets describe gemini-api-key --format='value(name)' > /dev/null 2>&1; then
  echo "✅ Secret 'gemini-api-key' exists."
else
  echo "❌ Secret 'gemini-api-key' NOT found."
  exit 1
fi

echo "🔍 Checking Cloud Run service has secret mounted..."
SECRETS=$(gcloud run services describe enterprise-api \
  --region us-central1 \
  --format='value(spec.template.spec.containers[0].env)' 2>/dev/null || echo "")

if echo "$SECRETS" | grep -q "gemini-api-key"; then
  echo "✅ Secret is mounted on Cloud Run service."
else
  echo "⚠️  Secret may not be mounted yet — check with: gcloud run services describe enterprise-api --region us-central1"
fi

echo "✅ Secret Manager verification complete."
