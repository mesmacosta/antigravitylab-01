#!/bin/bash
# Verifies Cloud SQL instance and database exist.
set -euo pipefail

echo "🔍 Checking Cloud SQL instance..."
if gcloud sql instances describe enterprise-db --format='value(state)' 2>/dev/null | grep -q "RUNNABLE"; then
  echo "✅ Cloud SQL instance 'enterprise-db' is RUNNABLE."
else
  echo "❌ Cloud SQL instance 'enterprise-db' not found or not running."
  exit 1
fi

echo "🔍 Checking database..."
if gcloud sql databases describe playbook_db --instance=enterprise-db > /dev/null 2>&1; then
  echo "✅ Database 'playbook_db' exists."
else
  echo "❌ Database 'playbook_db' NOT found."
  exit 1
fi

echo "🔍 Checking PostgreSQL version..."
DB_VERSION=$(gcloud sql instances describe enterprise-db --format='value(databaseVersion)')
if echo "$DB_VERSION" | grep -q "POSTGRES_16"; then
  echo "✅ PostgreSQL 16 confirmed."
else
  echo "⚠️  Expected POSTGRES_16, got: $DB_VERSION"
fi

echo "✅ Cloud SQL verification complete."
