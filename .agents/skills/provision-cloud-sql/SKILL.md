---
name: provision-cloud-sql
description: >
  Provisions a Cloud SQL PostgreSQL instance with the pgvector extension
  for RAG workloads. Use this when the user asks to set up a database,
  provision Cloud SQL, or enable vector search.
---

# Provision Cloud SQL with pgvector

## Goal
Create a Cloud SQL PostgreSQL 16 instance with pgvector enabled and create
the initial schema for storing document embeddings.

## When to use this skill
- User asks to set up a database for the application
- User wants vector search, embeddings storage, or RAG context
- User mentions Cloud SQL, PostgreSQL, or pgvector

## Do not use this skill when
- User asks about Firestore, Bigtable, or Spanner
- User wants a MySQL or SQL Server database
- A Cloud SQL instance named `enterprise-db` already exists

## Instructions
1. **Enable the API**:
   ```
   gcloud services enable sqladmin.googleapis.com
   ```
2. **Create the instance** (this takes 3-5 minutes):
   ```
   gcloud sql instances create enterprise-db \
     --database-version=POSTGRES_16 \
     --tier=db-f1-micro \
     --region=us-central1 \
     --database-flags=cloudsql.enable_pgvector=on
   ```
3. **Set the root password**:
   ```
   gcloud sql users set-password postgres \
     --instance=enterprise-db \
     --password=changeme-in-production
   ```
4. **Create the application database**:
   ```
   gcloud sql databases create playbook_db --instance=enterprise-db
   ```
5. **Connect and create the schema**:
   Instruct the user to run the following SQL using the Cloud SQL Studio in the Google Cloud Console (this avoids interactive prompt hanging for the agent):
   ```sql
   CREATE EXTENSION IF NOT EXISTS vector;

   CREATE TABLE documents (
     id SERIAL PRIMARY KEY,
     filename TEXT NOT NULL,
     content TEXT,
     embedding vector(768),
     metadata JSONB,
     created_at TIMESTAMPTZ DEFAULT NOW()
   );

   CREATE INDEX idx_documents_embedding ON documents
     USING ivfflat (embedding vector_cosine_ops) WITH (lists = 10);
   ```
6. **Validate**: Run `bash scripts/verify_cloudsql.sh`

## Constraints
- Use `db-f1-micro` tier to minimize cost in the lab environment.
- Use PostgreSQL 16 (not MySQL or SQL Server).
- ALWAYS enable `cloudsql.enable_pgvector=on`.

## Approval Gate
- HALT before creating the instance. Remind the user this incurs costs
  (~$0.01/hr for db-f1-micro) and to delete it after the lab.
