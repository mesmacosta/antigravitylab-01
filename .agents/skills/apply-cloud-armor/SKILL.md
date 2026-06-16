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
5. **Validate**: Run `bash .agents/skills/apply-cloud-armor/scripts/verify_armor.sh`

## Constraints
- Use pre-configured OWASP rules, do NOT write custom CEL expressions.
- Rate limit MUST be 100 requests per minute per IP.
- All commands use `gcloud compute` which is available in Cloud Shell.
