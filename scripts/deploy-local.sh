#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_dir"

corepack pnpm install --frozen-lockfile
corepack pnpm build
chmod 644 src/assets/article-index/article-indexer-cli 2>/dev/null || true

sha="$(git rev-parse --short=12 HEAD)-$(date +%Y%m%d%H%M%S)"
release="/var/www/newechoes/releases/$sha"
mkdir -p "$release"
rsync -a --delete dist/client/ "$release/"
ln -sfn "$release" /var/www/newechoes/current
find /var/www/newechoes/releases -mindepth 1 -maxdepth 1 -type d -printf '%T@ %p\n' \
  | sort -rn | tail -n +6 | cut -d' ' -f2- | xargs -r rm -rf

echo "Deployed $release"
