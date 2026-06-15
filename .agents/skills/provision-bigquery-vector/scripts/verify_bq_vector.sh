#!/bin/bash
set -e

PROJECT_ID=$(gcloud config get-value project)
echo "Verifying BigQuery Vector table 'document_embeddings'..."

if bq show ${PROJECT_ID}:enterprise_analytics.document_embeddings > /dev/null 2>&1; then
    echo "✅ BigQuery vector table found."
else
    echo "❌ BigQuery vector table missing."
    exit 1
fi
