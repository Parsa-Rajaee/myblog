#!/usr/bin/env sh

set -eu

site_dir="${1:-public}"

for path in \
  index.html \
  posts/80000hours/index.html \
  archives/index.html \
  tags/index.html \
  sitemap.xml \
  index.xml \
  404.html
do
  if [ ! -s "${site_dir}/${path}" ]; then
    echo "Missing or empty generated file: ${site_dir}/${path}" >&2
    exit 1
  fi
done

echo "Smoke tests passed for ${site_dir}"
