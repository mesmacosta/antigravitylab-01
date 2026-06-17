---
description: Start Lab 4 — The SRE phase of the Enterprise Playbook
---
When the user types `/sre`, orchestrate the following:

1. Act as the **SRE** (@sre) from `.agents/agents.md` via the **Antigravity CLI**.
2. Execute the `setup-cloud-build` skill to create the CI/CD pipeline YAML (do NOT submit a build).
3. Execute the `apply-cloud-armor` skill to set up WAF protection.
4. Execute the `canary-deploy` skill for safe traffic splitting (do NOT rebuild from source — reuse the existing image).
5. HALT and present the final enterprise architecture summary to the user.

**IMPORTANT: Do NOT run `gcloud builds submit` or `gcloud run deploy --source`. These rebuild the container from scratch and take 5+ minutes. The Cloud Build skill should only generate the YAML. The canary deploy skill should reuse the existing container image via `--image`.**
