---
description: Start Lab 3 — The Data Engineer phase of the Enterprise Playbook
---
When the user types `/dataengineer`, orchestrate the following:

1. Act as the **Data Engineer** (@dataengineer) from `.agents/agents.md`.
2. Execute the `provision-cloud-sql` skill to create the PostgreSQL + pgvector instance.
3. Execute the `stream-to-bigquery` skill to create the analytics pipeline.
4. Run both verification scripts.
5. HALT and present the database connection string and BigQuery table to the user.
