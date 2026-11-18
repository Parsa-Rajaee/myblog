# Site validation

Use Hugo Extended `0.150.0`, matching the version configured for Netlify.

## Local checks

Initialize the pinned PaperMod theme after cloning:

```sh
git submodule update --init --recursive
```

Build the site and run the generated-page smoke tests:

```sh
hugo --minify --destination public
./scripts/check-build.sh public
```

To check internal links locally, install [Lychee](https://github.com/lycheeverse/lychee) and run:

```sh
lychee --offline \
  --root-dir public \
  --remap "^https://parsarajaee\\.ir file:///absolute/path/to/public" \
  --no-progress \
  "public/**/*.html"
```

Replace `/absolute/path/to/public` with the absolute path to the local `public`
directory. The remap checks fully qualified links to this site's domain against
the generated files instead of the production website.

Confirm that validation did not rewrite article sources:

```sh
git diff --exit-code -- content
```

## Pull requests and deploy previews

GitHub Actions runs the build, smoke tests, and internal-link check on every push
and pull request. Netlify uses its deploy-preview context for pull requests.
Template and dependency upgrades should be reviewed in that preview before they
are merged to the production branch.
