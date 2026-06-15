---
name: provision-bigquery-vector
description: >
  Provisions a BigQuery table with an embedded vector column and a Vector Index
  for RAG workloads. Use this when the user asks to set up a vector database or
  enable vector search in under 10 seconds.
---

# Provision BigQuery Vector Search

## Goal
Create the BigQuery vector search table for storing document embeddings, providing an instant-provisioning alternative to Cloud SQL.

## When to use this skill
- User asks to set up a vector database for the application
- User wants vector search, embeddings storage, or RAG context
- User mentions BigQuery Vector Search

## Do not use this skill when
- User asks about Firestore or Cloud SQL

## Instructions
1. **Enable the API**:
   ```
   gcloud services enable bigquery.googleapis.com
   ```
2. **Create the table**:
   BigQuery requires `ARRAY<FLOAT64>` for vectors. The easiest way to create it is via DDL query:
   ```
   bq query --use_legacy_sql=false "
   CREATE TABLE IF NOT EXISTS \`${PROJECT_ID}.enterprise_analytics.document_embeddings\` (
     id STRING,
     filename STRING,
     content STRING,
     embedding ARRAY<FLOAT64>,
     metadata JSON,
     created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
   );"
   ```
3. **Seed the table**:
   BigQuery requires at least 5000 rows to create an IVF vector index. Run the seeding script to insert dummy data:
   ```
   python3 .agents/skills/provision-bigquery-vector/scripts/seed_bq.py
   ```
4. **Create the Vector Index**:
   ```
   bq query --use_legacy_sql=false "
   CREATE VECTOR INDEX IF NOT EXISTS my_index 
   ON \`${PROJECT_ID}.enterprise_analytics.document_embeddings\`(embedding) 
   OPTIONS(distance_type='COSINE', index_type='IVF');"
   ```
5. **Validate**: Run `bash .agents/skills/provision-bigquery-vector/scripts/verify_bq_vector.sh`

## Constraints
- Ensure the `enterprise_analytics` dataset exists first (the `stream-to-bigquery` skill creates it).
- `bq` CLI is pre-installed in Cloud Shell.
