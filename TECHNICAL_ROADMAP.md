# Technical Roadmap

## Purpose

This roadmap covers technical improvements to the Hugo blog. It does not include
writing, rewriting, reorganizing, or formatting article content.

## Project constraint

> Do not modify files under `content/`, including article text, headings, titles,
> front matter, tags, categories, or dates, unless the owner explicitly requests
> a specific content change.

Technical work may improve how existing content is rendered, but it must not
silently change the source content. A technical feature that requires a new
system page under `content/`, such as a search page, must be approved before that
file is created.

## What “rebuild based on the PaperMod template” means

Hugo resolves project templates before theme templates. Therefore the local
`layouts/_default/single.html` replaces PaperMod's article template instead of
only adding to it.

The local template currently implements its own article structure. As PaperMod
changes, this full override can miss theme features, fixes, accessibility
improvements, and markup changes. For example, PaperMod's current article
template includes extension hooks, cover rendering, anchored headings, optional
TOC rendering, post navigation, sharing, canonical metadata, and its standard
comment lifecycle.

“Rebuild based on PaperMod” does **not** mean redesigning posts or changing their
Markdown headings. It means removing the unnecessary full-template fork and
using PaperMod's supported extension points for local behavior.

### Recommended approach

1. Treat `themes/PaperMod/` as upstream code and do not edit it directly.
2. Use PaperMod's `layouts/single.html` as the article renderer.
3. Move the custom related-post block into
   `layouts/partials/extend_post_content.html`, which PaperMod calls after article
   content.
4. Keep `layouts/partials/comments.html` as the local Giscus integration.
5. Keep site-specific head additions in `layouts/partials/extend_head.html`.
6. Keep visual overrides in `assets/css/extended/custom.css`.
7. Remove `layouts/_default/single.html` only after comparing generated pages and
   confirming that required behavior remains available.

This architecture reduces duplicated theme markup and makes future PaperMod
updates safer.

## Current technical architecture

```text
MyBlog/
├── hugo.toml                         # Hugo and PaperMod configuration
├── netlify.toml                      # Netlify build configuration
├── content/                          # Owner-managed content; do not modify
├── archetypes/                       # Templates for future content creation
├── layouts/
│   ├── _default/single.html          # Full theme override to retire safely
│   └── partials/
│       ├── comments.html             # Local Giscus integration
│       └── extend_head.html          # Head extensions and analytics
├── assets/
│   └── css/extended/custom.css       # Site-specific visual overrides
├── static/                           # Fonts, images, favicon, and static files
└── themes/PaperMod/                  # Upstream Git submodule; do not edit
```

## Suggested architecture

```text
MyBlog/
├── hugo.toml
├── netlify.toml
├── content/                          # Protected from technical refactors
├── archetypes/
├── layouts/
│   └── partials/
│       ├── comments.html             # Giscus only
│       ├── extend_head.html          # Minimal site-wide head additions
│       └── extend_post_content.html  # Related posts and future post extensions
├── assets/
│   └── css/extended/custom.css       # Small, documented overrides
├── static/
│   ├── fonts/
│   ├── images/
│   └── favicon.*
├── .github/
│   └── workflows/
│       └── validate.yml              # Hugo build and link checks
└── themes/PaperMod/                  # Read-only upstream submodule
```

### Architecture rules

- Prefer configuration before overriding a template.
- Prefer PaperMod extension partials before overriding a complete template.
- Never edit `themes/PaperMod/` directly.
- Keep each local partial responsible for one feature.
- Keep JavaScript optional and auditable; do not ship obfuscated scripts.
- Keep the site functional without client-side JavaScript except where a feature
  inherently requires it, such as search or Giscus.
- Do not mix generated or downloaded webpage artifacts with source templates.
- Validate theme upgrades in a deploy preview before production deployment.

## Roadmap

### Phase 1 — Baseline and repository hygiene

**Goal:** Establish a clean, explainable, reproducible build without touching
content.

- [x] Move `enableRobotsTXT` out of the `[outputs]` table in `hugo.toml`.
- [x] Run `hugo --minify` and require a warning-free build.
- [x] Audit `static/js/main.js`, which contained an obfuscated Cloudflare challenge
      script.
- [x] Remove the script because no intentional, documented feature required it.
- [x] Audit `layouts/bas/`, `layouts/index_files/`, root `list.html`, temporary
      `tmpclaude-*` files, and duplicate image files.
- [x] Remove only artifacts confirmed to be unused.
- [x] Record the supported Hugo versions: local Hugo Extended `0.150.0` and
      Netlify Hugo `0.150.0`.
- [x] Confirm that the PaperMod Git submodule is pinned and reproducible at
      commit `154d006e0182dfc7da38008323976b02e6bfab4a`.

**Acceptance criteria**

- `hugo --minify` completes without warnings.
- Every shipped JavaScript file has a known purpose.
- No generated webpage artifacts are treated as source templates.
- The repository remains clean after a local build.

### Phase 2 — PaperMod-compatible template architecture

**Goal:** Minimize the local theme fork while preserving current behavior.

- [x] Capture representative generated HTML before refactoring.
- [x] Compare `layouts/_default/single.html` with PaperMod's
      `themes/PaperMod/layouts/single.html`.
- [x] Create `layouts/partials/extend_post_content.html` for related posts.
- [x] Localize technical UI text inside the related-post partial.
- [x] Ensure Giscus still loads through `layouts/partials/comments.html`.
- [x] Remove the full local single-page override after parity is confirmed.
- [ ] Verify archives, taxonomy pages, homepage pagination, and RSS output.
      Archives, pagination, primary taxonomy indexes, and primary feeds match
      the baseline. Full RSS stability is blocked by `هوش مصنوعی` and
      `هوش‌ مصنوعی` normalizing to the same tag URL.
- [ ] Verify RTL layout, mobile layout, light mode, and dark mode.
      Generated markup and responsive/theme assets are present; interactive
      visual checks remain.

**Acceptance criteria**

- Article rendering comes from the pinned PaperMod template.
- Custom behavior is implemented through local extension partials.
- No file under `content/` changes.
- Existing URLs and generated feeds remain stable.
- Future PaperMod updates require fewer manual template merges.

### Phase 3 — Automated validation and deployment safety

**Goal:** Detect regressions before Netlify deploys production.

- [x] Add a GitHub Actions workflow using the same Hugo version as Netlify.
- [x] Build with `hugo --minify` on pushes and pull requests.
- [x] Add an internal-link checker using Lychee `0.24.2`.
- [x] Check that the PaperMod submodule was initialized.
- [x] Add a small smoke-test list for the homepage, one post, archives, tags,
      sitemap, RSS, and 404 page.
- [x] Use Netlify deploy previews for template and dependency upgrades.
- [x] Document the local validation commands in `VALIDATION.md`.

**Acceptance criteria**

- Broken builds cannot be merged unnoticed.
- Internal broken links are reported automatically.
- CI and Netlify use compatible Hugo versions.
- Validation does not rewrite content files.

Repository branch protection must require the `Validate site / validate` status
check before the first acceptance criterion can be enforced rather than merely
reported.

### Phase 4 — Performance, security, and accessibility

**Goal:** Improve delivery quality without changing article source content.

- [ ] Add safe Netlify security headers such as `X-Content-Type-Options`,
      `Referrer-Policy`, and `Permissions-Policy`.
- [ ] Design a Content Security Policy only after inventorying Google Analytics,
      Giscus, YouTube embeds, and other external origins.
- [ ] Add cache headers for versioned assets, fonts, and images.
- [ ] Verify that custom fonts use `font-display: swap` and preload only assets
      proven to be critical.
- [ ] Remove unused JavaScript and duplicate static assets.
- [ ] Run Lighthouse against representative generated pages.
- [ ] Test keyboard navigation, focus visibility, color contrast, RTL behavior,
      and responsive layouts.
- [ ] Respect `prefers-reduced-motion` for any future animations.

**Acceptance criteria**

- No unexpected third-party scripts are delivered.
- Security headers do not break Giscus, analytics, or embeds.
- Lighthouse regressions are documented and actionable.
- Technical styling changes do not edit or rewrite Markdown content.

### Phase 5 — Optional technical features

These features are useful but should follow the foundation work.

#### Search

- [ ] Use PaperMod's built-in Fuse.js search and existing JSON home output.
- [ ] Test Persian characters and zero-width non-joiners.
- [ ] Add keyboard and screen-reader behavior tests.
- [ ] Obtain explicit approval before creating any required system page under
      `content/`.

#### Better related-post component

- [ ] Keep matching based on Hugo's existing related-content configuration.
- [ ] Limit output to a small number of relevant links.
- [ ] Hide the component when no related result exists.
- [ ] Keep the implementation in `extend_post_content.html`.

#### Theme-aware Giscus

- [ ] Synchronize Giscus with PaperMod's light/dark theme toggle.
- [ ] Avoid introducing a general-purpose JavaScript bundle for this one feature.
- [ ] Verify behavior when JavaScript or third-party cookies are restricted.

#### Operational observability

- [ ] Keep analytics loading documented and centralized.
- [ ] Add privacy-friendly analytics only if the current analytics no longer meets
      requirements.
- [ ] Avoid adding dashboards or services without a clear maintenance benefit.

## Explicitly out of scope

The following work must not be included in this technical roadmap unless it is
requested separately:

- Editing post text or Markdown headings.
- Rewriting titles, summaries, or descriptions.
- Changing post tags, categories, dates, or taxonomy structure.
- Adding cover images to existing posts.
- Correcting spelling or grammar in articles.
- Reorganizing existing articles.
- Creating editorial calendars or writing plans.

## Recommended implementation order

1. Fix the Hugo configuration warning.
2. Audit suspicious and obsolete files.
3. Add automated build validation.
4. Refactor the full article template override into PaperMod extension partials.
5. Run regression checks across generated page types.
6. Add security headers and performance checks.
7. Implement optional search and theme-aware Giscus only after the foundation is
   stable.

## Definition of done for technical changes

A technical task is complete when:

- The requested behavior works locally.
- `hugo --minify` succeeds without new warnings.
- Relevant generated pages have been checked.
- No unintended file under `content/` changed.
- The change does not edit the PaperMod submodule directly.
- New external scripts or services are documented.
- The final summary lists validation performed and any remaining risks.
