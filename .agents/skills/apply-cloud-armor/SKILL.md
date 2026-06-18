---
name: apply-cloud-armor
description: >
  Creates a Cloud Armor security policy with OWASP WAF rules and
  rate limiting. Use this when the user asks about WAF, DDoS protection,
  security policies, or Cloud Armor.
---

# Apply Cloud Armor WAF

## Goal
Protect the Cloud Run service with a Cloud Armor security policy
that blocks common OWASP attacks and rate-limits requests.

## When to use this skill
- User asks about WAF, DDoS protection, or security policies
- User wants to add OWASP protection rules to the service
- User mentions Cloud Armor, rate limiting, or XSS/SQLi protection

## Do not use this skill when
- User asks about application-level auth (use IAM or Firebase Auth)
- User wants network-level firewall rules (use VPC firewall)
- A Cloud Armor policy named `enterprise-waf` already exists

## Instructions
1. **Create the security policy**:
   ```
   gcloud compute security-policies create enterprise-waf \
     --description="Enterprise WAF policy for Cloud Run services"
   ```
2. **Add XSS protection rule**:
   ```
   gcloud compute security-policies rules create 1000 \
     --security-policy=enterprise-waf \
     --expression="evaluatePreconfiguredExpr('xss-v33-stable')" \
     --action=deny-403 \
     --description="Block XSS attacks"
   ```
3. **Add SQL injection protection rule**:
   ```
   gcloud compute security-policies rules create 1001 \
     --security-policy=enterprise-waf \
     --expression="evaluatePreconfiguredExpr('sqli-v33-stable')" \
     --action=deny-403 \
     --description="Block SQL injection"
   ```
4. **Add rate-limiting rule**:
   ```
   gcloud compute security-policies rules create 2000 \
     --security-policy=enterprise-waf \
     --src-ip-ranges="*" \
     --action=throttle \
     --rate-limit-threshold-count=100 \
     --rate-limit-threshold-interval-sec=60 \
     --conform-action=allow \
     --exceed-action=deny-429 \
     --enforce-on-key=IP \
     --description="Rate limit: 100 req/min per IP"
   ```
5. **Create Serverless NEG**:
   ```
   gcloud compute network-endpoint-groups create enterprise-api-neg \
     --region=us-central1 \
     --network-endpoint-type=serverless \
     --cloud-run-service=enterprise-api
   ```
6. **Create Global Backend Service**:
   ```
   gcloud compute backend-services create enterprise-api-backend \
     --load-balancing-scheme=EXTERNAL \
     --global
   ```
7. **Add NEG to Backend Service**:
   ```
   gcloud compute backend-services add-backend enterprise-api-backend \
     --global \
     --network-endpoint-group=enterprise-api-neg \
     --network-endpoint-group-region=us-central1
   ```
8. **Attach Cloud Armor Policy**:
   ```
   gcloud compute backend-services update enterprise-api-backend \
     --security-policy enterprise-waf \
     --global
   ```
9. **Create URL Map, Proxy, and Forwarding Rule**:
   ```
   gcloud compute url-maps create enterprise-api-url-map \
     --default-service enterprise-api-backend
     
   gcloud compute target-http-proxies create enterprise-api-http-proxy \
     --url-map enterprise-api-url-map
     
   gcloud compute forwarding-rules create enterprise-api-forwarding-rule \
     --load-balancing-scheme=EXTERNAL \
     --network-tier=PREMIUM \
     --global \
     --target-http-proxy=enterprise-api-http-proxy \
     --ports=80
   ```
10. **Restrict Cloud Run Ingress**:
    ```
    gcloud run services update enterprise-api \
      --region us-central1 \
      --ingress internal-and-cloud-load-balancing
    ```
11. **Validate**: Run `bash .agents/skills/apply-cloud-armor/scripts/verify_armor.sh`

## Constraints
- Use pre-configured OWASP rules, do NOT write custom CEL expressions.
- Rate limit MUST be 100 requests per minute per IP.
- All commands use `gcloud compute` and `gcloud run` which are available in Cloud Shell.
