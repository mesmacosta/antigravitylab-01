---
description: Start Lab 4 — The SRE phase of the Getting Started with the Antigravity Ecosystem
---

# SRE Workflow — Strict Runbook

You are the **SRE** (@sre). Follow this runbook **exactly and sequentially**.

## MANDATORY Execution Rules
- **Do NOT explore the workspace.** Do not list directories, read app code, or search the codebase.
- **Do NOT read previous conversation transcripts or logs.**
- **Do NOT attempt to verify if resources already exist** before creating them. If a resource already exists, let the command fail gracefully and move on.
- **ONLY read the three SKILL.md files listed below and the one template file.** No other files.
- **Execute the gcloud commands from each skill's Instructions section exactly as written.**
- Use `PROJECT_ID=$(gcloud config get-value project)` for project references.
- The service name is `enterprise-api` and the region is `us-central1`.

## Step 1 — Cloud Build CI/CD
1. Read `.agents/skills/setup-cloud-build/SKILL.md`
2. Execute its Instructions section (IAM grants + generate YAML from template)
3. Read the template at `.agents/skills/setup-cloud-build/references/cloudbuild.yaml.tmpl`
4. Write `infra/cloudbuild.yaml` based on the template
5. Verify with `cat infra/cloudbuild.yaml`
6. **Do NOT run `gcloud builds submit`**

## Step 2 — Cloud Armor & Load Balancer
1. Read `.agents/skills/apply-cloud-armor/SKILL.md`
2. Execute its Instructions section in full (create policy, rules, NEG, backend service, proxy, and restrict ingress).
3. Run verification: `bash .agents/skills/apply-cloud-armor/scripts/verify_armor.sh`

## Step 3 — Canary Deployment
1. Read `.agents/skills/canary-deploy/SKILL.md`
2. Execute Instructions steps 1-3 only (get image, deploy with --no-traffic, split 10%)
3. **Do NOT use `--source`. Use `--image` to reuse the existing container.**
4. HALT here and ask: "Canary is at 10%. Promote to 100% or rollback?"

## Step 4 — Summary
Present this table:
| Component | Status |
|-----------|--------|
| Cloud Build CI/CD | ✅ Generated `infra/cloudbuild.yaml` |
| Cloud Armor WAF | ✅ Policy `enterprise-waf` with OWASP rules |
| Canary Deploy | ⏸️ 10% traffic — awaiting user decision |
