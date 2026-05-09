# Antigravity Enterprise Playbook — Development Guide

## Prerequisites

| Tool | Install Command | Verify |
|------|----------------|--------|
| **Go** | `brew install go` | `go version` |
| **claat** | `go install github.com/googlecodelabs/tools/claat@latest` | `claat version` |
| **gcloud CLI** | [Install guide](https://cloud.google.com/sdk/docs/install) | `gcloud version` |

> Make sure `$(go env GOPATH)/bin` is in your PATH:
> ```bash
> export PATH=$PATH:$(go env GOPATH)/bin
> ```
> Add this to your `~/.zshrc` or `~/.bashrc` to persist across sessions.

## Project Structure

```
antigravitylab-01/
├── .agents/                   # Antigravity agent configuration
│   ├── agents.md              # Team personas (Developer, Architect, Data Engineer, SRE)
│   ├── skills/                # 8 pre-authored SKILL.md files with scripts
│   │   ├── scaffold-cloud-run-service/
│   │   ├── inject-secrets/
│   │   ├── wire-pubsub-eventarc/
│   │   ├── provision-cloud-sql/
│   │   ├── stream-to-bigquery/
│   │   ├── setup-cloud-build/
│   │   ├── apply-cloud-armor/
│   │   └── canary-deploy/
│   └── workflows/             # Slash command workflows (/developer, /architect, etc.)
├── codelabs/
│   ├── antigravity-enterprise-playbook.md    # Codelab source (claat markdown)
│   └── antigravity-enterprise-playbook/      # Exported HTML (generated)
│       ├── index.html
│       └── codelab.json
├── app/                       # Application code (generated during lab)
├── infra/                     # Infrastructure scripts (generated during lab)
└── docs/                      # This documentation
```

## Build the Codelab

### Export to HTML

```bash
cd codelabs
claat export antigravity-enterprise-playbook.md
```

This generates the `antigravity-enterprise-playbook/` directory containing `index.html` and `codelab.json`.

### Serve Locally

```bash
cd codelabs
claat serve -addr localhost:9090
```

Then open: [http://localhost:9090/antigravity-enterprise-playbook/](http://localhost:9090/antigravity-enterprise-playbook/)

### Rebuild After Edits

After editing `antigravity-enterprise-playbook.md`, re-export and the serve will pick up changes:

```bash
cd codelabs
claat export antigravity-enterprise-playbook.md
# If claat serve is already running, just refresh the browser
```

## Editing the Codelab

The codelab source is a single markdown file: `codelabs/antigravity-enterprise-playbook.md`

### Format Reference

- Full format guide: [FORMAT-GUIDE.md](https://github.com/googlecodelabs/tools/blob/main/FORMAT-GUIDE.md)
- Metadata block at the top (`summary`, `id`, `categories`, etc.)
- Each `## Heading` creates a new step
- `Duration: X:XX` sets the estimated time per step
- Code blocks use triple backticks with `console` language
- Info boxes: `Positive` (green) and `Negative` (orange) keywords on a blank line before the box content

### Key patterns

```markdown
## Step Title
Duration: 5:00

Regular content here.

Positive
: This is a green info box (tips, good-to-know info).

Negative
: This is an orange info box (warnings, cautions).
```

## Editing Skills

Skills live in `.agents/skills/<skill-name>/SKILL.md`. Each has:

- **YAML frontmatter**: `name` and `description` (used for semantic matching)
- **Instructions**: Step-by-step gcloud commands
- **Constraints**: Rules the agent must follow
- **Approval Gates**: Points where the agent must stop and ask the user
- **Validation scripts**: In `scripts/` subdirectory

To test a skill, open the workspace in Antigravity and ask a question that matches the skill's description. The agent should automatically activate it.

## Editing Workflows

Workflows live in `.agents/workflows/<name>.md`. Each maps a slash command (e.g., `/developer`) to a sequence of skills. Edit the workflow to change which skills are chained together.

## Quick Commands

| Action | Command |
|--------|---------|
| Export codelab | `cd codelabs && claat export antigravity-enterprise-playbook.md` |
| Serve locally | `cd codelabs && claat serve -addr localhost:9090` |
| List all skills | `find .agents/skills -name 'SKILL.md'` |
| List all workflows | `ls .agents/workflows/` |
| Validate scaffold | `python3 .agents/skills/scaffold-cloud-run-service/scripts/validate_scaffold.py` |
