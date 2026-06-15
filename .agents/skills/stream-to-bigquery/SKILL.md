---
name: stream-to-bigquery
description: >
  Creates a BigQuery dataset and table, and configures the Cloud Run
  service to stream processed document metadata into BigQuery. Use this
  when the user asks about analytics, BigQuery, or data streaming.
---

# Stream Data to BigQuery

## Goal
Create the BigQuery analytics layer and update the Cloud Run service
to stream document processing results for analysis.

## When to use this skill
- User asks about analytics, reporting, or data streaming
- User wants to store processed document metadata in BigQuery
- User mentions BigQuery, data warehouse, or streaming inserts

## Do not use this skill when
- User asks about real-time dashboards (use Looker Studio separately)
- User wants batch ETL jobs instead of streaming inserts
- The BigQuery dataset `enterprise_analytics` already exists

## Instructions
1. **Enable the API**:
   ```
   gcloud services enable bigquery.googleapis.com
   ```
2. **Create the dataset**:
   ```
   bq mk --dataset --location=us-central1 ${PROJECT_ID}:enterprise_analytics
   ```
3. **Create the table** with schema:
   ```
   bq mk --table ${PROJECT_ID}:enterprise_analytics.processed_docs \
     filename:STRING,upload_date:TIMESTAMP,tags:STRING,word_count:INTEGER,processing_time_ms:INTEGER,status:STRING
   ```
4. **Update `app/main.py`** to add BigQuery streaming insert logic
   using `google-cloud-bigquery` client library. **CRITICAL**: If `app/main.py` does not exist, do NOT create it. Assume the Developer will implement it later.
5. **Add** `google-cloud-bigquery` to `app/requirements.txt` (skip if the file does not exist).
6. **Validate**: Run `bash .agents/skills/stream-to-bigquery/scripts/verify_bq.sh`

## Constraints
- Use `us-central1` location to co-locate with Cloud Run.
- Use streaming inserts (`insert_rows_json`), not batch loads.
- `bq` CLI is pre-installed in Cloud Shell — no additional installs needed.
