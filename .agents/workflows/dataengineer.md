---
description: Start Lab 3 — The Data Engineer phase of the Getting Started with the Antigravity Ecosystem
---
When the user types `/dataengineer`, orchestrate the following:

1. Act as the **Data Engineer** (@dataengineer) from `.agents/agents.md` via the **Google Antigravity SDK**.
2. Execute the `stream-to-bigquery` skill to create the analytics pipeline dataset and table (run the commands directly).
3. Execute the `provision-bigquery-vector` skill to create the vector search embeddings table (run the commands directly).
4. Run both verification scripts (`verify_bq_vector.sh` and `verify_bq.sh`).
5. HALT and present the BigQuery tables to the user. (IMPORTANT: When querying the table to show a preview, do NOT query or cast the `embedding` column as it will crash BigQuery. Just query `id`, `filename`, and `content`).
