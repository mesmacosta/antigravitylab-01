---
name: canary-deploy
description: >
  Performs a canary deployment by splitting traffic between Cloud Run
  revisions. Use this when the user asks about safe rollouts, canary
  deployments, blue-green, or traffic splitting.
---

# Canary Deployment on Cloud Run

## Goal
Deploy a new revision and gradually shift traffic to validate stability
before full promotion.

## When to use this skill
- User asks about safe rollouts, canary deployments, or blue-green deploys
- User wants to split traffic between Cloud Run revisions
- User mentions gradual rollout or traffic management

## Do not use this skill when
- User wants a full immediate deployment (use `gcloud run deploy` directly)
- User asks about A/B testing with different backends
- No existing revision is serving traffic yet (first deploy)

## Instructions
1. **Deploy a new revision** with a tag (no traffic yet):
   ```
   gcloud run deploy enterprise-api \
     --source app/ \
     --region us-central1 \
     --no-traffic \
     --tag canary
   ```
2. **Split traffic** — send 10% to canary:
   ```
   gcloud run services update-traffic enterprise-api \
     --region us-central1 \
     --to-tags canary=10
   ```
3. **Monitor** using Cloud Logging (available in Cloud Shell):
   ```
   gcloud logging read 'resource.type="cloud_run_revision" AND
     resource.labels.service_name="enterprise-api" AND severity>=ERROR' \
     --limit=10 --format='table(timestamp,textPayload)'
   ```
4. **If healthy**, promote to 100%:
   ```
   gcloud run services update-traffic enterprise-api \
     --region us-central1 \
     --to-tags canary=100
   ```
5. **If errors detected**, rollback:
   ```
   gcloud run services update-traffic enterprise-api \
     --region us-central1 \
     --to-tags canary=0
   ```

## Approval Gate
- HALT after step 2 (10% traffic split). Show the user the monitoring command
  output and ask: "The canary is receiving 10% of traffic. Do you want to
  promote to 100% or rollback?"

## Constraints
- NEVER go directly to 100% traffic on a new revision.
- ALWAYS start at 10% and wait for user approval.
- All commands use `gcloud run` which is available in Cloud Shell.
