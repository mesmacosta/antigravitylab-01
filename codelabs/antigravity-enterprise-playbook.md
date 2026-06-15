summary: The Enterprise Playbook for Mastering the Agentic Future on Google Cloud
id: antigravity-enterprise-playbook
categories: Cloud, AI, Antigravity
environments: Web
status: Published
feedback link: https://github.com/mesmacosta/antigravitylab-01/issues
authors: Developer Ecosystem - Americas Team
tags: antigravity, cloud-run, enterprise, skills

# Building with Google Antigravity — The Enterprise Playbook

## Introduction
Duration: 5:00

This workshop is the definitive enterprise playbook for mastering the agentic future on Google Cloud. We provide an end-to-end roadmap that guides you from the first vibe of an idea to a full-scale, operational reality.

Across four interconnected labs, you will learn how the specialized skills of a **Developer**, **Architect**, **Data Engineer**, and **SRE** must converge to create, manage, and scale enterprise-grade systems — all powered by Google Antigravity's agent-driven workflows.

### What you'll build

A serverless, event-driven **document processing pipeline** on Google Cloud that:

* Ingests files via Cloud Storage
* Processes them through a Cloud Run microservice
* Stores embeddings in Cloud SQL with pgvector
* Streams metadata into BigQuery for analytics
* Is protected by Cloud Armor WAF
* Deploys safely via canary releases

### What you'll learn

* How to define AI personas with `agents.md`
* How to program deterministic agent behavior with **Antigravity Skills**
* How to orchestrate multi-step workflows with custom **slash commands**
* How to scaffold, secure, instrument, and safely deploy Cloud Run services using only `gcloud` CLI

### What you'll need

* The **Antigravity 2.0 Ecosystem** tools:
  * [Antigravity 2.0 (The Command Center)](https://antigravity.google/docs/command-center/install) installed locally
  * [Antigravity IDE](https://antigravity.google/docs/ide/install) installed locally
  * *Note: The SDK and CLI will be used in Cloud Shell later.*
* A Google Cloud Project with billing enabled
* **Owner** role on the GCP project (or at minimum: `Editor` + `Security Admin` + `Service Usage Admin`)
* [gcloud CLI](https://cloud.google.com/sdk/docs/install) installed and authenticated
* [Git](https://git-scm.com/downloads) installed
* Basic familiarity with Python and the terminal

Positive
: **CLI Compatibility**: All `gcloud`, `bq`, and `python3` commands in this lab are compatible with GCP Cloud Shell tooling. Since Antigravity runs on your local machine, the agent executes these commands locally via your authenticated `gcloud` CLI.

## Set Up Your Environment
Duration: 5:00

### Create or select a Google Cloud project

1. Open the [Google Cloud Console](https://console.cloud.google.com/).
2. Select or create a new project.
3. Ensure billing is enabled.

### Understand the Agentic Ecosystem Setup

This workshop uses the interconnected Antigravity 2.0 Ecosystem:
1. **The Tool Interfaces (Your Local Machine)**: You will interact with the agent through 4 distinct tools depending on the persona: the Antigravity IDE, the 2.0 Command Center, the Python SDK, and the CLI.
2. **The Execution Environment (Hybrid)**: Lab 1 and 2 execute `gcloud` commands locally. For Lab 3 and 4, we will transition to **GCP Cloud Shell** to demonstrate that the Antigravity SDK and CLI can run entirely in the cloud without any local dependencies.

### Authenticate locally

Since the Agent runs on your local machine, you must authenticate your local `gcloud` CLI:

```console
gcloud auth login
gcloud auth application-default login
```

### Set your Project ID

Set your active project to the one you created or selected above. Replace `YOUR_PROJECT_ID` with your actual project ID:

```console
gcloud config set project YOUR_PROJECT_ID
export PROJECT_ID=$(gcloud config get-value project)
echo "Project ID: $PROJECT_ID"
```

Positive
: Verify the output shows your expected project ID before continuing. If it's blank or incorrect, re-run `gcloud config set project` with the correct value.

### Enable required APIs

```console
gcloud services enable \
  run.googleapis.com \
  artifactregistry.googleapis.com \
  secretmanager.googleapis.com \
  eventarc.googleapis.com \
  pubsub.googleapis.com \
  sqladmin.googleapis.com \
  bigquery.googleapis.com \
  cloudbuild.googleapis.com \
  compute.googleapis.com \
  storage.googleapis.com
```

Positive
: This command enables 10 APIs and may take **1-2 minutes** to complete. Wait for it to finish before continuing.

### Clone the starter repo

The starter repo contains all the pre-authored Antigravity Skills, workflows, and validation scripts:

```console
git clone https://github.com/mesmacosta/antigravitylab-01.git
cd antigravitylab-01
```

### Open the workspace

1. Choose the appropriate Antigravity tool for the current lab (we'll start with the Antigravity IDE).
2. Open the `antigravitylab-01` folder as a workspace (e.g., via **File > Open Folder**).
3. Start a new conversation in this workspace.

Positive
: **Troubleshooting Tip**: Generative AI workflows can occasionally get confused. If the agent ever seems stuck or provides an unexpected response, simply tell it to "Stop" and re-run your slash command, or open a fresh conversation.

### Explore the workspace structure

Take a moment to explore the pre-authored files. In the Antigravity IDE terminal or your system terminal, run:

```console
find .agents -type f | sort
```

You should see:

```
.agents/agents.md
.agents/skills/apply-cloud-armor/SKILL.md
.agents/skills/apply-cloud-armor/scripts/verify_armor.sh
.agents/skills/canary-deploy/SKILL.md
.agents/skills/inject-secrets/SKILL.md
.agents/skills/inject-secrets/scripts/verify_secrets.sh
.agents/skills/provision-cloud-sql/SKILL.md
.agents/skills/provision-cloud-sql/scripts/verify_cloudsql.sh
.agents/skills/scaffold-cloud-run-service/SKILL.md
.agents/skills/scaffold-cloud-run-service/scripts/validate_scaffold.py
.agents/skills/setup-cloud-build/SKILL.md
.agents/skills/setup-cloud-build/references/cloudbuild.yaml.tmpl
.agents/skills/stream-to-bigquery/SKILL.md
.agents/skills/stream-to-bigquery/scripts/verify_bq.sh
.agents/skills/wire-pubsub-eventarc/SKILL.md
.agents/skills/wire-pubsub-eventarc/scripts/verify_pubsub.sh
.agents/workflows/architect.md
.agents/workflows/dataengineer.md
.agents/workflows/developer.md
.agents/workflows/sre.md
```

Positive
: **8 Skills** are pre-authored with hardcoded `gcloud` commands, validation scripts, and constraints. They act as guardrails — preventing the agent from deviating during the workshop.

## Understand the Architecture
Duration: 3:00

Before we start building, let's understand the four personas and what each lab accomplishes.

### The Team (`agents.md`)

Open `.agents/agents.md` to see the four personas:

| Persona | Role | Ecosystem Tool | Lab |
|---------|------|----------------|-----|
| **@developer** | Scaffolds Flask microservices for Cloud Run | **Antigravity IDE** | Lab 1 |
| **@architect** | Secures with Secret Manager + wires Eventarc | **Antigravity 2.0 Desktop** | Lab 2 |
| **@dataengineer** | Provisions Cloud SQL + BigQuery pipelines | **Antigravity SDK** | Lab 3 |
| **@sre** | Sets up CI/CD, WAF, and canary deploys | **Antigravity CLI** | Lab 4 |

### Skills as Guardrails

Each persona has dedicated **Skills** — `SKILL.md` files containing:

* **Precise `gcloud` templates** so the agent cannot pick the wrong command
* **Constraints** ("Do NOT create a Dockerfile")
* **Approval Gates** ("HALT and ask the user before proceeding")
* **Validation scripts** that deterministically verify each step

### Slash Command Workflows

Each lab is triggered by a single slash command:

* `/developer` — Lab 1
* `/architect` — Lab 2
* `/dataengineer` — Lab 3
* `/sre` — Lab 4

## Lab 1: The Developer
Duration: 15:00

**Focus**: Moving from the "vibe of an idea" to a deployed Cloud Run service.

**Skill activated**: `scaffold-cloud-run-service`

### Run the workflow

Open the **Antigravity IDE** and type:

```
/developer
```

The agent will:

1. Adopt the **@developer** persona
2. Scaffold a Flask application in `app/` with:
   * `main.py` — Flask API with `/health` and `/process` endpoints (including `/` for Eventarc events)
   * `requirements.txt` — Flask, gunicorn, google-cloud-logging
   * `Procfile` — Gunicorn configuration for Buildpacks
3. Run the validation script
4. Deploy to Cloud Run

### What happens behind the scenes

The `scaffold-cloud-run-service` skill constrains the agent to:

* Use **Flask only** (not Django or FastAPI)
* Use **Buildpacks** (no Dockerfile)
* Use `os.environ.get()` for config (no hardcoded secrets)

### Observe the deployment

The agent will run:

```console
cd app && gcloud run deploy enterprise-api \
  --source . \
  --region us-central1 \
  --allow-unauthenticated
```

Positive
: `gcloud run deploy --source .` uses **Google Cloud Buildpacks** to automatically containerize your Python app. No Dockerfile needed!

Negative
: **Enterprise Warning**: If you are running this in a corporate Google Cloud environment, the deployment might fail with an IAM error regarding `allUsers`. This is caused by a **Domain Restricted Sharing** Organization Policy. If this happens, ask the agent to "Deploy again, but do not allow unauthenticated access."

Positive
: The first deployment in a project may prompt you to create an **Artifact Registry** repository. Type `Y` to confirm if prompted.

### Validate the scaffold

The agent runs the validation script automatically, but you can also run it manually:

```console
python3 .agents/skills/scaffold-cloud-run-service/scripts/validate_scaffold.py
```

### Verify the deployment

Once deployed, test the health endpoint:

```console
SERVICE_URL=$(gcloud run services describe enterprise-api \
  --region us-central1 --format='value(status.url)')
curl ${SERVICE_URL}/health
```

You should see a JSON response like:

```json
{"status": "ok"}
```

### What you built

* ✅ A production-ready Flask microservice
* ✅ Deployed to Cloud Run with Buildpacks
* ✅ Health check endpoint at `/health`
* ✅ No hardcoded secrets, no Dockerfile

## Lab 2: The Architect
Duration: 10:00

**Focus**: Designing the security perimeter and event-driven architecture.

**Skills activated**: `inject-secrets`, `wire-pubsub-eventarc`

### Run the workflow

Open **Antigravity 2.0 (The Command Center)**, ensure you have opened the `antigravitylab-01` workspace folder, and type:

```
/architect
```

The agent will:

1. Adopt the **@architect** persona
2. Create a secret in **Secret Manager** and bind it to Cloud Run
3. Create a **Pub/Sub topic** and **GCS bucket**
4. Wire an **Eventarc trigger** for file upload events
5. Run verification scripts

### Part 1: Secret Manager

The `inject-secrets` skill will:

1. Create a secret called `gemini-api-key` with a placeholder value
2. Grant the Cloud Run service account access
3. Mount the secret as an environment variable

```console
printf "PLACEHOLDER_KEY_FOR_LAB" | gcloud secrets create gemini-api-key \
  --data-file=- \
  --replication-policy=automatic
```

Negative
: **Security Best Practice**: Never hardcode API keys in source code. Always use Secret Manager to inject them at runtime.

### Part 2: Event-Driven Architecture

The `wire-pubsub-eventarc` skill will:

1. Grant the **GCS Service Agent** the `roles/pubsub.publisher` role (required so GCS can publish file upload events to Pub/Sub)
2. Create a Pub/Sub topic for document processing
3. Create a GCS bucket for document ingestion
4. Create an Eventarc trigger routing `google.cloud.storage.object.v1.finalized` events to Cloud Run

Negative
: **Fresh Project Warning**: On a brand-new project, the Eventarc Service Agent may not be initialized yet. If the trigger creation fails with `FAILED_PRECONDITION`, wait 1-2 minutes after enabling the APIs and try again. The agent handles this automatically, but if you run into issues, you can force initialization by running: `gcloud eventarc providers describe google.cloud.storage --location=us-central1`

### Verify

Run the verification scripts in your **system terminal** (from the `antigravitylab-01` directory), or ask the agent to verify for you:

```console
bash .agents/skills/inject-secrets/scripts/verify_secrets.sh
bash .agents/skills/wire-pubsub-eventarc/scripts/verify_pubsub.sh
bash .agents/skills/wire-pubsub-eventarc/scripts/verify_eventarc_e2e.sh
```

### Test the event pipeline

Upload a test file to trigger the pipeline:

```console
echo "Hello from the Enterprise Playbook" > test-doc.txt
gcloud storage cp test-doc.txt gs://${PROJECT_ID}-doc-intake/
```

Check the Cloud Run logs:

```console
gcloud logging read 'resource.type="cloud_run_revision" AND
  resource.labels.service_name="enterprise-api"' \
  --limit=5 --format='table(timestamp,textPayload)'
```

### What you built

* ✅ Secrets securely injected via Secret Manager
* ✅ Event-driven pipeline: GCS → Eventarc → Cloud Run
* ✅ Zero hardcoded credentials

## Lab 3: The Data Engineer
Duration: 20:00

**Focus**: Building the data layer for document embeddings and analytics.

**Skills activated**: `provision-cloud-sql`, `stream-to-bigquery`

### Run the workflow

To demonstrate that Antigravity tools can run anywhere, we will transition to the cloud. Open **[Google Cloud Shell](https://shell.cloud.google.com/)** in your browser, or click the **Activate Cloud Shell** button (terminal icon) at the top-right of the [Google Cloud Console](https://console.cloud.google.com/).

First, clone the lab repository and set your Project ID inside the Cloud Shell session (since this is a fresh environment):

```console
git clone https://github.com/mesmacosta/antigravitylab-01.git
cd antigravitylab-01
export PROJECT_ID=$(gcloud config get-value project)
```

Next, install the Python SDK:

```console
pip install google-antigravity-sdk
```

Next, trigger the workflow programmatically in Python. Create the script and run it:

```console
cat > trigger.py << 'EOF'
import antigravity

agent = antigravity.Agent(workspace=".")
agent.trigger_workflow("/dataengineer")
EOF

python3 trigger.py
```

The agent will:

1. Adopt the **@dataengineer** persona
2. Provision a **Cloud SQL PostgreSQL 16** instance with pgvector
3. Create the document embeddings schema
4. Set up a **BigQuery** dataset and table for analytics
5. Update the Cloud Run service to stream data to BigQuery

Negative
: **Cost Notice**: The Cloud SQL `db-f1-micro` instance costs ~$0.01/hr. Remember to delete it after the lab (see Clean Up step).

### Part 1: Cloud SQL with pgvector

The `provision-cloud-sql` skill creates:

* A PostgreSQL 16 instance with `cloudsql.enable_pgvector=on`
* A `playbook_db` database
* A `documents` table with a `vector(768)` column for embeddings

```console
gcloud sql instances create enterprise-db \
  --database-version=POSTGRES_16 \
  --tier=db-f1-micro \
  --region=us-central1 \
  --database-flags=cloudsql.enable_pgvector=on
```

Positive
: To avoid interactive password prompts that can hang agent workflows, the agent will output the schema SQL and instruct you to run it visually using **Cloud SQL Studio** in the Google Cloud Console. *(Hint: When asked to log in to Cloud SQL Studio, use the username `postgres` and leave the password blank).*

Negative
: **Wait Time**: The `gcloud sql instances create` command takes **5-10 minutes** to complete. This is normal — the agent will wait. In a live workshop, this is a good time for the presenter to explain the pgvector embedding architecture.

### Part 2: BigQuery Analytics

The `stream-to-bigquery` skill creates:

```console
bq mk --dataset --location=us-central1 ${PROJECT_ID}:enterprise_analytics
bq mk --table ${PROJECT_ID}:enterprise_analytics.processed_docs \
  filename:STRING,upload_date:TIMESTAMP,tags:STRING,word_count:INTEGER,processing_time_ms:INTEGER,status:STRING
```

### Verify

Run the verification scripts in your **Cloud Shell** terminal:

```console
bash .agents/skills/provision-cloud-sql/scripts/verify_cloudsql.sh
bash .agents/skills/stream-to-bigquery/scripts/verify_bq.sh
```

### What you built

* ✅ Cloud SQL PostgreSQL 16 with pgvector for RAG embeddings
* ✅ BigQuery analytics pipeline for processed documents
* ✅ Cloud Run service updated with streaming inserts

## Lab 4: The SRE
Duration: 10:00

**Focus**: CI/CD automation, security hardening, and safe deployments.

**Skills activated**: `setup-cloud-build`, `apply-cloud-armor`, `canary-deploy`

### Run the workflow

Continue using your open **Google Cloud Shell** session.

First, install the Antigravity CLI:

```console
pip install google-antigravity-cli
```

Then, trigger the workflow via the terminal (you should still be in the `antigravitylab-01` directory from Lab 3):

```console
antigravity run /sre
```

Positive
: If you opened a new Cloud Shell tab, re-run `cd antigravitylab-01` first.

The agent will:

1. Adopt the **@sre** persona
2. Set up a **Cloud Build** CI/CD pipeline
3. Create a **Cloud Armor** WAF policy with OWASP rules
4. Perform a **canary deployment** with traffic splitting

### Part 1: Cloud Build CI/CD

The `setup-cloud-build` skill reads the golden template from `references/cloudbuild.yaml.tmpl` and submits a build:

Positive
: Behind the scenes, the agent grants the **Cloud Build Service Account** the `roles/run.admin` and `roles/iam.serviceAccountUser` roles. This is required so Cloud Build can deploy new revisions to Cloud Run on your behalf.

```console
gcloud builds submit --config=infra/cloudbuild.yaml app/
```

Verify the build succeeded:

```console
gcloud builds list --limit=1 --format='table(id,status,createTime)'
```

### Part 2: Cloud Armor WAF

The `apply-cloud-armor` skill creates a security policy with:

* **XSS protection** (OWASP xss-v33-stable)
* **SQL injection protection** (OWASP sqli-v33-stable)
* **Rate limiting** (100 requests/min per IP)

```console
gcloud compute security-policies create enterprise-waf \
  --description="Enterprise WAF policy for Cloud Run services"
```

Negative
: **Architecture Note**: Cloud Armor cannot be attached directly to a Cloud Run service. It requires a Global External Application Load Balancer. Setting up a Load Balancer takes ~15 minutes and requires domain/SSL setup, which is outside the scope of this lab. The agent *authors* the WAF policy, but it remains unattached for now.

### Part 3: Canary Deployment

The `canary-deploy` skill deploys a new revision without traffic, then gradually shifts:

```console
gcloud run deploy enterprise-api \
  --source app/ \
  --region us-central1 \
  --no-traffic \
  --tag canary
```

Then splits traffic — 10% to canary:

```console
gcloud run services update-traffic enterprise-api \
  --region us-central1 \
  --to-tags canary=10
```

Positive
: The agent will **HALT** after the 10% split and ask you: "Do you want to promote to 100% or rollback?" This is the Approval Gate in action!

### Monitor the canary

```console
gcloud logging read 'resource.type="cloud_run_revision" AND
  resource.labels.service_name="enterprise-api" AND severity>=ERROR' \
  --limit=10 --format='table(timestamp,textPayload)'
```

If healthy, promote:

```console
gcloud run services update-traffic enterprise-api \
  --region us-central1 \
  --to-tags canary=100
```

### Verify

Run the verification script in your **Cloud Shell** terminal:

```console
bash .agents/skills/apply-cloud-armor/scripts/verify_armor.sh
```

### What you built

* ✅ Automated CI/CD with Cloud Build
* ✅ Authored Cloud Armor WAF rules (XSS, SQLi, rate limiting)
* ✅ Safe canary deployments with traffic splitting

## Conclusion and Clean Up
Duration: 5:00

Congratulations! You have built a complete enterprise-grade system on Google Cloud using Google Antigravity.

### What you've accomplished

Across four labs, you converged the skills of four personas:

| Lab | Persona | Tool | What You Built |
|-----|---------|------|----------------|
| 1 | Developer | Antigravity IDE | Flask API on Cloud Run with Buildpacks |
| 2 | Architect | Antigravity 2.0 | Secret Manager + Eventarc event pipeline |
| 3 | Data Engineer | Python SDK | Cloud SQL pgvector + BigQuery streaming |
| 4 | SRE | Antigravity CLI | Cloud Build CI/CD + Cloud Armor WAF (policy authored) + Canary deploys |

### Key takeaways

* **Skills as Guardrails**: Pre-authored `SKILL.md` files constrain agent behavior and eliminate common errors.
* **Approval Gates**: Critical operations (secret creation, traffic splitting) require human confirmation.
* **Validation Scripts**: Every resource is verified by deterministic scripts — no guesswork.
* **CLI Portable**: Every command uses standard tooling. The SDK and CLI run seamlessly in Cloud Shell, proving that the Antigravity ecosystem doesn't strictly require a local desktop UI.

### Beyond the Lab: The Official Skills Registry

In this lab, we used highly constrained "Guardrail Skills" to ensure a deterministic workshop experience. In the real world, you'll want to equip your agents with broad, generalized knowledge.

Explore the official **[Google Skills Repository](https://github.com/google/skills)** to discover foundational skills like `cloud-run-basics` and `bigquery-basics` that empower your agents to architect and deploy resources dynamically.

### Clean up resources

To avoid ongoing charges, delete the resources created during this lab. Run the following in your **Cloud Shell** session or any terminal where `gcloud` is authenticated to your project:

```console
# Ensure Project ID is set
export PROJECT_ID=$(gcloud config get-value project)

# Delete Cloud Run service
gcloud run services delete enterprise-api --region us-central1 --quiet

# Delete Cloud SQL instance
gcloud sql instances delete enterprise-db --quiet

# Delete GCS bucket
gcloud storage rm -r gs://${PROJECT_ID}-doc-intake/ --quiet

# Delete Pub/Sub topic
gcloud pubsub topics delete document-processing --quiet

# Delete Eventarc trigger
gcloud eventarc triggers delete doc-upload-trigger --location=us-central1 --quiet

# Delete Secret Manager secret
gcloud secrets delete gemini-api-key --quiet

# Delete BigQuery dataset
bq rm -r -f ${PROJECT_ID}:enterprise_analytics

# Delete Cloud Armor policy
gcloud compute security-policies delete enterprise-waf --quiet

# Delete Cloud Build artifacts (optional)
gcloud artifacts repositories delete cloud-run-source-deploy \
  --location=us-central1 --quiet 2>/dev/null || true
```

### Next steps

* [Getting Started with Google Antigravity](https://codelabs.developers.google.com/getting-started-google-antigravity)
* [Authoring Antigravity Skills](https://codelabs.developers.google.com/getting-started-with-antigravity-skills)
* [Build and Deploy to GCP with Antigravity](https://codelabs.developers.google.com/build-and-deploy-gcp-with-antigravity)
* [Official Google Skills Repository](https://github.com/google/skills)
* [Antigravity Documentation](https://antigravity.google/docs)

### Reference docs

* [Cloud Run Documentation](https://cloud.google.com/run/docs)
* [Secret Manager Documentation](https://cloud.google.com/secret-manager/docs)
* [Eventarc Documentation](https://cloud.google.com/eventarc/docs)
* [Cloud SQL Documentation](https://cloud.google.com/sql/docs)
* [BigQuery Documentation](https://cloud.google.com/bigquery/docs)
* [Cloud Build Documentation](https://cloud.google.com/build/docs)
* [Cloud Armor Documentation](https://cloud.google.com/armor/docs)
