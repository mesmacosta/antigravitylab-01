#!/bin/bash
# End-to-end verification of Eventarc trigger from GCS to Cloud Run
set -euo pipefail

PROJECT_ID=$(gcloud config get-value project 2>/dev/null)
BUCKET_NAME="${PROJECT_ID}-doc-intake"
SERVICE_NAME="enterprise-api"
REGION="us-central1"
TEST_FILE="/tmp/e2e-test-doc.json"

echo "🔍 Starting end-to-end Eventarc validation..."

# 1. Create a test file
echo '{"test": true, "message": "E2E verification upload"}' > "$TEST_FILE"

# 2. Upload to GCS
echo "⬆️  Uploading test file to gs://${BUCKET_NAME}..."
if ! gcloud storage cp "$TEST_FILE" "gs://${BUCKET_NAME}/e2e-test-doc.json" > /dev/null 2>&1; then
    echo "❌ Failed to upload file to GCS. Does the bucket exist?"
    exit 1
fi

echo "⏳ Waiting 30 seconds for Eventarc propagation and Cloud Run processing..."
sleep 30

for i in {1..3}; do
    echo "📝 Checking Cloud Run logs for service ${SERVICE_NAME} (Attempt $i/3)..."
    LOGS=$(gcloud logging read "resource.type=\"cloud_run_revision\" AND resource.labels.service_name=\"${SERVICE_NAME}\" AND textPayload:\"Process endpoint called\"" --limit=1 --format="value(textPayload)" --freshness=5m 2>/dev/null || echo "")
    
    if [[ -n "$LOGS" ]]; then
        echo "✅ Eventarc end-to-end test passed! Event reached Cloud Run successfully."
        echo "   Log output: $LOGS"
        exit 0
    fi
    echo "   Not found yet, waiting 15 seconds..."
    sleep 15
done

echo "❌ Eventarc end-to-end test failed. Could not find process log in Cloud Run."
echo "   Please check Eventarc trigger configuration or Cloud Run logs manually."
exit 1
