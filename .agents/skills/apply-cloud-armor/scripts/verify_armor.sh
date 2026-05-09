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
RULES=$(gcloud compute security-policies rules list \
  --security-policy=enterprise-waf \
  --format='value(priority)' 2>/dev/null)

for RULE in 1000 1001 2000; do
  if echo "$RULES" | grep -q "$RULE"; then
    echo "✅ Rule $RULE exists."
  else
    echo "❌ Rule $RULE NOT found."
    exit 1
  fi
done

echo "✅ Cloud Armor verification complete."
