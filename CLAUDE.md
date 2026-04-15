## Personal Preferences

- Direct, detailed, casual, and concise tone.
- Structure long responses with bullets for readability.
- Include hyperlinks when referencing repos, tickets, documentation, or wiki pages.
- Prioritize immediately useful outputs: editable drafts, structured analysis, brainstorming, and concise summaries.
- Offer multiple options when helpful, but keep them grounded and actionable.
- Do not guess when correctness matters — verify technical claims against documentation or the codebase.
- If something is uncertain, say so clearly and identify what needs to be verified.
- Do not be overly agreeable — push back when needed rather than validating incorrect assumptions.
- Avoid shortcuts, hand-wavy recommendations, vague filler, or generic AI phrasing.
- When quoting references, include the quote first, then the source link.
- When using a table with yes/no values, use ✅ and ❌ instead of text for readability.

---

## Content Types

The devsite serves two distinct types of content, each with its own authoring workflow:

**Dev Biz** (document-based authoring)
- Content lives in Google Drive (Google Docs/Sheets), following the standard [AEM Edge Delivery Services](https://experienceleague.adobe.com/en/docs/experience-manager-cloud-service/content/edge-delivery/overview) model
- Authors use the [AEM Sidekick](https://www.aem.live/docs/sidekick) browser extension to preview and publish content
- EDS parses the documents and generates semantic HTML for delivery
- No code required — content updates go live without rebuilds

**Dev Docs** (GitHub markdown-based)
- Content lives in GitHub repos as Markdown files under `src/pages/`
- Not a native EDS content source — the [`devsite-runtime-connector`](https://github.com/aemsites/devsite-runtime-connector) transforms the markdown into EDS-compatible HTML at request time
- Content is deployed via GitHub Actions (not Sidekick)
- Developers author and review changes through standard GitHub workflows (branches, PRs)
- Reference site: [developer-stage.adobe.com/dev-docs-reference](https://developer-stage.adobe.com/dev-docs-reference/) — source: [dev-docs-reference](https://github.com/AdobeDocs/dev-docs-reference/blob/main/src/pages/index.md)

**Gatsby** (legacy tech stack)
- Older Adobe developer sites use [Gatsby](https://www.gatsbyjs.com/) with the [aio-theme](https://github.com/adobe/aio-theme) component library
- Content is also markdown-based, which is why migration to DevDocs is feasible without a full rewrite
- DevDocs intentionally keeps block syntax similar to aio-theme so content authors don't have to change much
- Sites being migrated from Gatsby to DevDocs should refer to the [DevDocs migration best practices](https://developer-stage.adobe.com/dev-docs-reference/getting-started/dev-docs/best-practices/)

Key differences / migration notes:
- **File naming**: EDS requires kebab-case — no underscores, periods, or uppercase in filenames (folders are more lenient)
- **Assets**: Must be under `src/pages/`, not a `static/` folder (exception: JSON files for Redocly must be in `static/`)
- **Trailing slashes**: Gatsby tolerates invalid trailing slashes; EDS does not — use `redirects.json` to cover old bookmarks during transition
- **Horizontal rules**: `---`, `* * *`, and `<hr>` are not supported; replace with `<HorizontalLine />`
- **HTML tags / custom CSS**: Not supported — escape HTML characters or use EDS block equivalents
- **Block replacements**: Hero → Superhero, Teaser/AnnouncementBlock → Announcement, TextBlock → Cards or Columns, ListBlock → List, TabsBlock → Tab, Media → Embed, openAPISpec → RedoclyAPIBlock
- **Links**: Use `[ ]` not `< >`; relative paths must include filename and extension (e.g. `index.md`); anchor links only work on deployed stage, not local dev
- **Config.md**: In Gatsby, Home is optional; in EDS, Home must be the first path under Pages

---

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

Dev Biz Sidekick:
- Library: https://main--adp-devsite--adobedocs.aem.live/tools/sidekick/library.html?plugin=blocks
- Source (Google Drive): https://drive.google.com/drive/u/0/folders/1bzYUsqvroGP1EUCMgIQe0Mh3maKVbfUm

---

## AEM URL Format

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

---

## Routing

In deployed environments, Fastly routes requests based on path prefix:
- **Dev Biz paths** (`helix_transclusion_table`) — served directly from the AEM host
- **Dev Docs paths** (`adp_docs_table`) — routed to the runtime connector

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

## Workflows

### Deploying Dev Biz Content (Google Drive / Sidekick)

- Edit in `adobe.io-stage` → Sidekick preview → verify on developer-stage.adobe.com
- Copy files from `adobe.io-stage` to `adobe.io` → Sidekick preview + publish → live on developer.adobe.com

### Deploying Dev Docs Content (GitHub-based content repos)

- Create a branch in the content repo, make edits
- Use GitHub Action to deploy to stage from the branch (passes `x-content-source-authorization: branchName` header)
- Verify on developer-stage.adobe.com → merge branch to main
- Use GitHub Action to deploy to production from main

### Editing Devsite Code (adp-devsite)

- Create a branch off of `AdobeDocs/adp-devsite`
- Push changes → available at `branchName--adp-devsite--adobedocs.aem.page` (prod content) or `branchName--adp-devsite-stage--adobedocs.aem.page` (stage content)
- Any push to the repo immediately updates the deployed code
- PR to `stage` branch when changes look good; `stage` is merged to `main` on production release

---

## Shared CI/CD Infrastructure

Dev Docs content repos (like `dev-docs-reference`) don't define their own CI logic — they delegate to three shared repos:

**[adp-devsite-workflow](https://github.com/AdobeDocs/adp-devsite-workflow)** — reusable GitHub Actions workflows (`workflow_call`)
- Content repos reference these via `uses: AdobeDocs/adp-devsite-workflow/.github/workflows/XXX.yml@main`
- `deploy.yml` — deploys changed (or all) files to stage/prod via AEM preview/live APIs, then busts the CDN cache
- `validate-pr.yml` — runs markdown linting on `src/pages/**` changes on PRs; posts results to the job summary
- `build-auto-generated-files.yml` — builds contributor lists and site metadata

**[adp-devsite-scripts](https://github.com/AdobeDocs/adp-devsite-scripts)** — Node.js scripts used by the workflows at runtime
- Checked out as a sibling repo during CI (not installed as an npm package)
- `deploy.js` — makes AEM preview/live/cache API calls
- `get-path-prefix.js` — reads the content repo's config to determine the URL path prefix for routing
- `linter-bot/postLinterReport.js` — posts lint results as PR comments

**[adp-devsite-utils](https://github.com/AdobeDocs/adp-devsite-utils)** — CLI tool for markdown linting and utilities
- Invoked in CI via `npx --yes github:AdobeDocs/adp-devsite-utils runLint`
- Custom remark lint rules in `linters/` (frontmatter checks, no HTML tags, alt text, filename conventions, etc.)
- `bin/` utilities: build redirections, Fastly redirect management, site metadata, link normalization

---

## Local Dev Architecture

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
- `dev-docs-reference` — reference documentation content; stage site at https://developer-stage.adobe.com/dev-docs-reference/, source at https://github.com/AdobeDocs/dev-docs-reference/blob/main/src/pages/index.md
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
