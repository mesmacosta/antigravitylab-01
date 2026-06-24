#!/bin/bash
# Verifies Cloud Armor security policy exists with required rules.
set -euo pipefail

echo "🔍 Checking Cloud Armor policy..."
if gcloud compute security-policies describe enterprise-waf > /dev/null 2>&1; then
  echo "✅ Security policy 'enterprise-waf' exists."
else
  echo "❌ Security policy 'enterprise-waf' NOT found."
  exit 1
fi

echo "🔍 Checking WAF rules..."
RULES=$(gcloud compute security-policies describe enterprise-waf \
  --format='value(rules.priority)' 2>/dev/null)

for RULE in 1000 1001 2000; do
  if echo "$RULES" | grep -q "$RULE"; then
    echo "✅ Rule $RULE exists."
  else
    echo "❌ Rule $RULE NOT found."
    exit 1
  fi
done

echo "✅ Cloud Armor verification complete."

echo "🔍 Checking Load Balancer and Ingress restriction..."

if gcloud compute backend-services describe enterprise-api-backend --global > /dev/null 2>&1; then
  echo "✅ Backend service 'enterprise-api-backend' exists."
else
  echo "❌ Backend service 'enterprise-api-backend' NOT found."
  exit 1
fi

POLICY_ATTACHED=$(gcloud compute backend-services describe enterprise-api-backend --global --format='value(securityPolicy)')
if [[ "$POLICY_ATTACHED" == *"enterprise-waf"* ]]; then
  echo "✅ Cloud Armor policy is attached to the backend service."
else
  echo "❌ Cloud Armor policy is NOT attached to the backend service."
  exit 1
fi

INGRESS=$(gcloud run services describe enterprise-api --region us-central1 --format='value(metadata.annotations."run.googleapis.com/ingress")')
if [[ "$INGRESS" == "internal-and-cloud-load-balancing" ]]; then
  echo "✅ Cloud Run ingress is properly restricted."
else
  echo "❌ Cloud Run ingress is NOT restricted (Current: $INGRESS). It is vulnerable to bypass."
  exit 1
fi

echo "✅ Full perimeter verification complete."
