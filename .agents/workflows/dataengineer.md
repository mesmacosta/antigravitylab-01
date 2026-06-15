---
description: Start Lab 3 — The Data Engineer phase of the Enterprise Playbook
---
When the user types `/dataengineer`, orchestrate the following:

1. Act as the **Data Engineer** (@dataengineer) from `.agents/agents.md` via the **Google Antigravity SDK**.
2. Execute the `provision-cloud-sql` skill to create the PostgreSQL + pgvector instance (run the gcloud/bq commands directly, do not write a bash script).
3. Execute the `stream-to-bigquery` skill to create the analytics pipeline (run the commands directly).
4. Run both verification scripts (`verify_cloudsql.sh` and `verify_bq.sh`).
5. HALT and present the database connection string and BigQuery table to the user.
