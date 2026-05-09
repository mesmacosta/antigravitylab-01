#!/usr/bin/env python3
"""Validates the scaffolded Cloud Run service meets enterprise requirements."""
import sys
import os
import re

errors = []
warnings = []
app_dir = os.path.join(os.getcwd(), "app")

# 1. Check main.py exists and has required endpoints
main_path = os.path.join(app_dir, "main.py")
if not os.path.exists(main_path):
    errors.append("app/main.py not found.")
else:
    content = open(main_path).read()
    if "/healthz" not in content:
        errors.append("app/main.py missing /healthz endpoint.")
    if "os.environ" not in content and "os.getenv" not in content:
        warnings.append("app/main.py may have hardcoded config (no os.environ usage found).")
    # Check for hardcoded API keys
    if re.search(r'(AIza[0-9A-Za-z_-]{35}|[0-9]+-[a-z0-9_]{32})', content):
        errors.append("Possible hardcoded API key detected in main.py!")

# 2. Check requirements.txt
req_path = os.path.join(app_dir, "requirements.txt")
if not os.path.exists(req_path):
    errors.append("app/requirements.txt not found.")
else:
    reqs = open(req_path).read().lower()
    for dep in ["flask", "gunicorn"]:
        if dep not in reqs:
            errors.append(f"Missing dependency '{dep}' in requirements.txt.")

# 3. Check Procfile
proc_path = os.path.join(app_dir, "Procfile")
if not os.path.exists(proc_path):
    warnings.append("app/Procfile not found (Buildpacks may still work without it).")

# 4. Check NO Dockerfile
if os.path.exists(os.path.join(app_dir, "Dockerfile")):
    errors.append("Dockerfile found! Use Buildpacks instead — delete the Dockerfile.")

# Report
if warnings:
    print("⚠️  Warnings:")
    for w in warnings:
        print(f"  {w}")

if errors:
    print("❌ Scaffold validation FAILED:")
    for e in errors:
        print(f"  {e}")
    sys.exit(1)
else:
    print("✅ Scaffold validation passed — ready for Cloud Run deployment.")
    sys.exit(0)
