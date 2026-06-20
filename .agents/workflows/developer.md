---
description: Start Lab 1 — The Developer phase of the Getting Started with the Antigravity Ecosystem
---
When the user types `/developer`, orchestrate the following:

1. Act as the **Developer** (@developer) from `.agents/agents.md` using the **Antigravity IDE**.
2. Execute the `scaffold-cloud-run-service` skill to create the Flask API.
3. Run the validation script to confirm the scaffold is correct.
4. Deploy to Cloud Run using `gcloud run deploy --source .`.
5. HALT and report the deployed Cloud Run URL to the user.
