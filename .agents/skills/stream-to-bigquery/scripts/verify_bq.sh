#!/bin/bash
# Verifies BigQuery dataset and table exist.
set -euo pipefail

echo "🔍 Checking BigQuery dataset..."
if bq show ${PROJECT_ID}:enterprise_analytics > /dev/null 2>&1; then
  echo "✅ Dataset 'enterprise_analytics' exists."
else
  echo "❌ Dataset 'enterprise_analytics' NOT found."
  exit 1
fi

echo "🔍 Checking BigQuery table..."
if bq show ${PROJECT_ID}:enterprise_analytics.processed_docs > /dev/null 2>&1; then
  echo "✅ Table 'processed_docs' exists."
else
  echo "❌ Table 'processed_docs' NOT found."
  exit 1
fi

echo "🔍 Checking table schema..."
SCHEMA=$(bq show --format=json ${PROJECT_ID}:enterprise_analytics.processed_docs 2>/dev/null | python3 -c "
import sys, json
data = json.load(sys.stdin)
fields = [f['name'] for f in data.get('schema', {}).get('fields', [])]
print(','.join(fields))
")
echo "  Fields: $SCHEMA"

echo "✅ BigQuery verification complete."
