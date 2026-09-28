# Blog user guide

This guide covers the normal workflow for writing, previewing, and publishing
posts. The site is built with Hugo Extended `0.150.0`, uses the PaperMod theme,
and is deployed by Netlify.

## First-time setup

Install these tools:

- [Git](https://git-scm.com/)
- [Hugo Extended 0.150.0](https://github.com/gohugoio/hugo/releases/tag/v0.150.0)

After cloning the repository, initialize the pinned PaperMod theme:

```sh
git submodule update --init --recursive
```

Confirm that Hugo is available:

```sh
hugo version
```

The output should report Hugo Extended `0.150.0`.

## Preview the site locally

Start Hugo's local development server from the repository root:

```sh
hugo server -D
```

Open the local URL printed by Hugo, normally `http://localhost:1313/`.
The `-D` flag includes draft posts. Hugo updates the preview when a source file
changes.

Stop the server with `Ctrl+C`.

## Create a post

Posts use Hugo page bundles. Each post has its own directory containing an
`index.md` file and any images used by that post.

Choose a short, lowercase ASCII slug because it becomes part of the permanent
URL. For example, create a post with the slug `my-new-post`:

```sh
hugo new content posts/my-new-post/index.md
```

The resulting URL will be:

```text
https://parsarajaee.ir/posts/my-new-post/
```

Avoid renaming a published post directory. Doing so changes its URL and can
break existing links.

## Configure front matter

The metadata block at the top of `index.md` controls the post title, date,
draft status, categories, and tags. Existing posts primarily use YAML front
matter, as in this example:

```yaml
---
title: "عنوان نوشته"
date: 2026-09-12T10:00:00+03:30
draft: true
categories:
  - "نام دسته"
tags:
  - "نام تگ"
  - "تگ دیگر"
---
```

Keep `draft: true` while working. Change it to `draft: false` only when the post
is ready to publish.

Use existing category and tag spelling consistently. Visually similar Persian
strings can produce conflicting URLs. In particular, do not mix
`هوش مصنوعی` with `هوش‌ مصنوعی`; the second form contains a zero-width
non-joiner, but Hugo normalizes both to `/tags/هوش-مصنوعی/`.

## Write content

Write the article below the front matter using Markdown:

```markdown
## یک عنوان فرعی

این یک پاراگراف است.

[متن پیوند](https://example.com/)

- مورد اول
- مورد دوم

> یک نقل‌قول
```

The main post title comes from `title` in the front matter, so do not repeat it
as a level-one Markdown heading.

### Add images

Place an image beside the post's `index.md` file:

```text
content/posts/my-new-post/
├── index.md
└── image1.jpg
```

Reference it with a relative path:

```markdown
![توضیح تصویر](image1.jpg)
```

Use meaningful alternative text for accessibility. Prefer optimized images and
clear filenames; very large files slow down page loads and deployments.

## Publish a post

Before publishing:

1. Preview the post with `hugo server -D`.
2. Check the title, date, links, images, categories, and tags.
3. Change `draft: true` to `draft: false`.
4. Run the local validation steps.

Build and smoke-test the generated site:

```sh
hugo --minify --destination public
./scripts/check-build.sh public
```

See `VALIDATION.md` for the optional local Lychee command and more validation
details.

Review the changes before committing:

```sh
git status
git diff
```

Stage only the intended post bundle, commit it, and push your branch:

```sh
git add content/posts/my-new-post
git commit -m "Add my new post"
git push
```

Do not use `git push --force` for the normal publishing workflow.

GitHub Actions validates every push and pull request. Netlify creates a deploy
preview for pull requests and publishes the production site after changes reach
the configured production branch. For template or dependency changes, inspect
the deploy preview before merging.

## Edit existing pages

Common owner-managed files include:

- `content/about.md` — the About page
- `content/archives.md` — the archive page configuration
- `content/posts/<slug>/index.md` — an existing article

Preview and validate edits in the same way as a new post. Avoid changing the
`url`, post directory, or published date unless the resulting URL or chronology
change is intentional.

## Site settings

Site-wide settings are in `hugo.toml`, including:

- site title and base URL
- navigation menu
- homepage introduction
- social links
- PaperMod display options
- Giscus comment settings

Change one setting at a time and preview the result locally. Never place API
keys or private credentials in `hugo.toml` or another committed file.

## Files not to edit manually

- `public/` and `resources/` are generated build output.
- `themes/PaperMod/` is a pinned Git submodule and should be treated as upstream
  code.
- `.github/workflows/validate.yml` controls automated validation.
- `layouts/` and `assets/` contain site implementation and styling rather than
  article content.

Normal writing work should stay under `content/` and, when needed, `static/`.

## Troubleshooting

### The theme is missing

If Hugo reports that PaperMod is unavailable, initialize the submodule:

```sh
git submodule update --init --recursive
```

### Draft post is not visible

Use `hugo server -D`, or change the post to `draft: false` when it is ready to
publish.

### An image is missing

Confirm that the image is in the same page-bundle directory as `index.md` and
that the filename, capitalization, and Markdown path match exactly.

### CI fails

Open the failed `Validate site` job in GitHub Actions and inspect the first
failing step:

- **Verify PaperMod submodule**: the submodule was not initialized correctly.
- **Build site**: Hugo found a configuration, template, or content error.
- **Run smoke tests**: an expected generated page is missing.
- **Check internal links**: a generated internal link points to a missing file.
- **Verify content was not rewritten**: validation changed a file under
  `content/`, which it must not do.
