# Workspace Context

## Scope
- This file provides shared context for repositories under `/Users/melissag/Projects`.
- Use repo-local `AGENTS.md` files for details that only apply to a specific repository.
- Treat this file as institutional knowledge and cross-repo orientation, not a task tracker.

## Working Model
- Many repositories in this workspace are related and are often debugged together.
- Do not assume the current repo is the only source of truth for a problem.
- Before proposing a fix, consider whether the issue belongs in a sibling repo, shared workflow repo, or local integration setup.
- Prefer preserving established cross-repo conventions unless a repo-local `AGENTS.md` says otherwise.

## Repo Families
- `adp-devsite`, `dev-site`, and similar repos are site or platform repos that own routing, theme, templates, or local entry points.
- Content repos such as `dev-docs-reference`, `adp-devsite-github-actions-test`, `adp-dev-docs-private`, and many product-docs repos usually serve markdown and assets from `src/pages/`.
- Utility and shared tooling repos such as `adp-devsite-utils` may own linting, scripts, or reusable build behavior used by content repos.
- Some repos in this workspace are experiments, prototypes, or product-specific docs sites; do not assume every repo participates in the devsite pipeline.

## Cross-Repo Expectations
- When investigating a docs issue, consider whether the fix belongs in the content repo, runtime connector, site/router repo, or shared workflow/tooling repo.
- When a repo looks "too small" to explain its own behavior, check whether it delegates CI or build logic to a shared repo.
- When a local issue appears only in one environment, check environment-specific routing, content source, deployment headers, and preview/publish behavior.
- If a repo name or structure suggests an older stack, confirm whether it is Gatsby, Dev Docs, or another legacy pattern before making migration assumptions.

## Devsite Mental Model
- The devsite ecosystem serves multiple content models with different authoring and deployment paths.
- `Dev Biz` is document-based and uses Google Drive, AEM Edge Delivery Services, and Sidekick.
- `Dev Docs` is markdown-based in GitHub under `src/pages/`, then transformed into EDS-compatible HTML by a runtime connector.
- `Gatsby` repos are legacy markdown-based sites and may still influence current migration work.
- Many bugs come from applying the wrong assumptions across those models.

## Devsite Content Rules
- EDS assets generally belong under `src/pages/`.
- Redocly JSON files are a common exception and may belong in `static/`.
- Use kebab-case for filenames. Avoid underscores, periods, and uppercase in filenames.
- Relative links should include filename and extension, such as `index.md`.
- Anchor links are more trustworthy on deployed stage than in local dev.
- Avoid raw HTML tags and custom CSS in markdown content; prefer supported block equivalents.
- Horizontal rules such as `---`, `* * *`, and `<hr>` are not supported; use `<HorizontalLine />`.

## Migration Notes
- Common Gatsby to EDS replacements include:
- `Hero` -> `Superhero`
- `Teaser` or `AnnouncementBlock` -> `Announcement`
- `TextBlock` -> `Cards` or `Columns`
- `ListBlock` -> `List`
- `TabsBlock` -> `Tab`
- `Media` -> `Embed`
- `openAPISpec` -> `RedoclyAPIBlock`
- `config.md` differs between stacks: `Home` may be optional in Gatsby but must be first under `Pages` in EDS.
- Gatsby may tolerate URL patterns that EDS does not; redirects are often needed during migration.

## Environments
- The main devsite environments are dev, stage, and production.
- Stage uses `developer-stage.adobe.com`.
- Production uses `developer.adobe.com`.
- Dev uses `developer-dev.adobe.com`.
- Stage content commonly comes from `adobe.io-stage`.
- Production and dev often default to `adobe.io` content unless deployment behavior overrides the content source.

## URL And Content Source Behavior
- AEM URLs follow `{branch}--{repo}--{github-org}.aem.page`.
- The branch in the URL identifies deployed code, not necessarily the content branch being served.
- The `x-content-source-authorization` header can determine whether branch-specific stage content is used.
- If content looks wrong on the expected branch URL, check deployment headers and content source assumptions before changing code.

## Routing And Path Registration
- Fastly routes by path prefix.
- Some paths are served directly from the AEM host.
- Dev Docs paths are routed through the runtime connector.
- New docs path prefixes usually need registration in `devsitepaths.json`.
- Stage path changes are often previewed without publish.
- Production and dev path changes commonly require preview and publish.

## Shared CI/CD
- Some content repos delegate workflow behavior to shared repos rather than defining everything locally.
- `adp-devsite-workflow` contains reusable GitHub Actions workflows.
- `adp-devsite-scripts` contains scripts used by those workflows.
- `adp-devsite-utils` contains linting and utility tooling.
- If CI behavior seems missing from the active repo, inspect shared workflow/tooling repositories before assuming the repo is incomplete.

## Local Dev Heuristics
- Local docs rendering may depend on multiple repos running together, not just the currently open one.
- A common setup includes:
- a site/router repo on `:3000`
- a theme or aem-cli process on `:3001`
- a runtime connector on `:3002`
- a content repo on `:3003`
- When local docs pages break, check router, rendering layer, runtime connector, and content repo together.
- Startup order and port expectations matter in this ecosystem.

## Change Heuristics
- When changing rendering behavior, ask whether the problem belongs in content, connector, site code, or shared tooling.
- When changing routing behavior, verify path registration and environment-specific routing.
- When changing deployment behavior, check shared workflow repositories before patching local config.
- When working across sibling repos, avoid fixing the symptom in one repo if the source of truth lives elsewhere.
- When uncertain, search the sibling repos under `/Users/melissag/Projects` before concluding the current repo owns the behavior.
