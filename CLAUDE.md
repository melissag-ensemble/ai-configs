## Environments

Three environments exist, each with its own Fastly host, Google Drive content source, and deploy process.

| Environment | URL | Fastly Host | Google Drive |
|---|---|---|---|
| Stage | developer-stage.adobe.com | `stage--adp-devsite-stage--adobedocs.aem.page` | adobe.io-stage |
| Production | developer.adobe.com | `main--adp-devsite--adobedocs.aem.live` | adobe.io |
| Dev | developer-dev.adobe.com | `main--adp-devsite--adobedocs.aem.page` | adobe.io |

Google Drive folders:
- `adobe.io-stage`: https://drive.google.com/drive/folders/1TNL03Z8uSfNR_bj1gW8I-yY0Q96e7dtd
- `adobe.io`: https://drive.google.com/drive/folders/1cV6zhxBY6zrAAqA_HalWeDAH4mPloY7T

### Understanding the AEM URL Format

`{branch}--{repo}--{github-org}.aem.page`

- The branch segment = which code branch is deployed
- The repo segment = which GitHub repo (e.g. `adp-devsite`, `adp-devsite-stage`)
- The org segment = GitHub org (`adobedocs`)

Examples:
- `stage--adp-devsite-stage--adobedocs.aem.page` — stage branch of adp-devsite, with stage content
- `main--adp-devsite--adobedocs.aem.live` — main branch of adp-devsite, production content
- `branchName--adp-devsite--adobedocs.aem.page` — feature branch code with prod content
- `branchName--adp-devsite-stage--adobedocs.aem.page` — feature branch code with stage content

### Content Source and the Authorization Header

The `x-content-source-authorization: branchName` header (set by GitHub Actions) determines which content is served:
- **With** the header → content served from that specific branch (stage Google Drive / `adobe.io-stage`)
- **Without** the header → content served from the `adobe.io` Google Drive folder (production)

This means the same AEM URL can serve different content depending on whether the GitHub Action that deployed it passed the authorization header.

### How Routing Works (Deployed)

In deployed environments, Fastly handles routing based on the path prefix:
- **Dev Biz paths** (`helix_transclusion_table`) — served directly from the AEM host
- **Dev Docs paths** (`adp_docs_table`) — routed to the runtime connector

### Deploying Content

**Dev Biz content** (Google Drive / Sidekick):
- Edit in `adobe.io-stage` → Sidekick preview → verify on developer-stage.adobe.com
- Copy files from `adobe.io-stage` to `adobe.io` → Sidekick preview + publish → live on developer.adobe.com

**Dev Docs content** (GitHub-based content repos):
- Create a branch in the content repo, make edits
- Use GitHub Action to deploy to stage from the branch (passes `x-content-source-authorization: branchName` header)
- Verify on developer-stage.adobe.com → merge branch to main
- Use GitHub Action to deploy to production from main

### Editing Devsite Code (adp-devsite)

- Create a branch off of `AdobeDocs/adp-devsite`
- Push changes → available at `branchName--adp-devsite--adobedocs.aem.page` (prod content) or `branchName--adp-devsite-stage--adobedocs.aem.page` (stage content)
- Any push to the repo immediately updates the deployed code
- PR to `stage` branch when changes look good; `stage` is merged to `main` on production release

### Adding a New Path

To register a new docs path prefix so the router knows where to send it:

**Stage:** Edit the `devsitepaths.json` spreadsheet in `adobe.io-stage/franklin_assets/` → Sidekick preview (do NOT publish)
- Spreadsheet: https://docs.google.com/spreadsheets/d/1GqZ6QJwOhSG-beyd0nIEJ_cHd5PGBTghsqhbTM9nqMs

**Prod/Dev:** Edit the `devsitepaths.json` spreadsheet in `adobe.io/franklin_assets/` → Sidekick preview AND publish
- Spreadsheet: https://docs.google.com/spreadsheets/d/1V_mVmnlREEQgCM8XA2VNXtRhoTlrFFSCF3Wh_8-4ig

Fastly table names:
- Dev Biz paths: `helix_transclusion_table`
- Dev Docs paths: `adp_docs_table`

---

## Multi-Server Dev Architecture (Local)

Three servers must run together to produce a local EDS (Franklin/AEM) page.

### Servers and Ports

| Repo | Command | Port | Role |
|---|---|---|---|
| `adp-devsite` | `npm run dev` | **3000** | Entry point / router proxy |
| `adp-devsite` (aem-cli) | (spawned by `dev`) | **3001** | Renders EDS blocks, styles, scripts (`adp-devsite` repo as the "theme") |
| `devsite-runtime-connector` | `npm run dev` | **3002** | Transforms markdown docs into EDS-compatible HTML |
| content repo | `npm run dev` | **3003** | Serves raw content files (`.md`, assets) from `src/pages/` |

**Content repos** (any one runs on `:3003`):
- `adp-devsite-github-actions-test` — test/example content repo
- `dev-docs-reference` — reference documentation content
- `dev-docs-template` — template used to bootstrap new EDS content repos; clone this when creating a new docs site

### How a Request Flows (Local Dev)

1. Browser hits `localhost:3000` (the router in `adp-devsite/dev.mjs`)
2. The router fetches `devsitepaths.json` from the stage AEM instance to know which URL path prefixes belong to docs content repos vs. the main devsite
3. **If the path matches a docs prefix** → request goes to `:3002` (runtime connector), which fetches the raw markdown from `:3003` (content repo), transforms it to HTML, and injects EDS styles/scripts from `:3001`
4. **If the path does not match** → request goes directly to `:3001` (aem-cli serving `adp-devsite` blocks/templates)

### Startup

Run each in its own terminal in this order:
1. `adp-devsite` — `npm run dev` (starts both `:3000` and `:3001`)
2. `devsite-runtime-connector` — `npm run dev` (starts `:3002`)
3. content repo (e.g. `adp-devsite-github-actions-test`) — `npm run dev` (starts `:3003`)
