## Multi-Server Dev Architecture

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

### How a Request Flows

1. Browser hits `localhost:3000` (the router in `adp-devsite/dev.mjs`)
2. The router fetches `devsitepaths.json` from the stage AEM instance to know which URL path prefixes belong to docs content repos vs. the main devsite
3. **If the path matches a docs prefix** → request goes to `:3002` (runtime connector), which fetches the raw markdown from `:3003` (content repo), transforms it to HTML, and injects EDS styles/scripts from `:3001`
4. **If the path does not match** → request goes directly to `:3001` (aem-cli serving `adp-devsite` blocks/templates)

### Startup

Run each in its own terminal in this order:
1. `adp-devsite` — `npm run dev` (starts both `:3000` and `:3001`)
2. `devsite-runtime-connector` — `npm run dev` (starts `:3002`)
3. content repo (e.g. `adp-devsite-github-actions-test`) — `npm run dev` (starts `:3003`)
