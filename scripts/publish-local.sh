#!/usr/bin/env bash
# Publish a throwaway test build to the GitHub Packages npm registry.
# Gitignored on purpose. Does not touch package.json permanently or ~/.npmrc.
#
# Usage:   scripts/publish-local.sh
# Env:
#   SCOPE      npm scope = GitHub owner of the package (default: owner of `origin`)
#   TAG        dist-tag (default: dev)
#   NPM_TOKEN  token with write:packages (default: `gh auth token`)
#              if gh's token lacks the scope: gh auth refresh -s write:packages
set -euo pipefail

cd "$(dirname "$0")/.."

REGISTRY="https://npm.pkg.github.com"
TAG="${TAG:-dev}"
SCOPE="${SCOPE:-$(git remote get-url origin | sed -E 's#.*[:/]([^/]+)/[^/]+(\.git)?$#\1#')}"
SCOPE="$(echo "$SCOPE" | tr '[:upper:]' '[:lower:]')"
TOKEN="${NPM_TOKEN:-$(gh auth token)}"

BASE_NAME="$(jq -r .name package.json | sed 's#^@[^/]*/##')"
BASE_VERSION="$(jq -r .version package.json)"
# Unique prerelease version so republishing never collides (versions are immutable)
VERSION="${BASE_VERSION}-dev.$(date +%Y%m%d%H%M%S)"
NAME="@${SCOPE}/${BASE_NAME}"
# GitHub links a package to a repo via package.json "repository"
REPO_SLUG="$(git remote get-url origin | sed -E 's#^.*[:/]([^/]+/[^/]+)$#\1#; s#\.git$##')"
REPO_URL="https://github.com/${REPO_SLUG}"

TMP_NPMRC="$(mktemp)"
cp package.json package.json.bak
cleanup() {
  mv -f package.json.bak package.json
  rm -f "$TMP_NPMRC"
}
trap cleanup EXIT

cat > "$TMP_NPMRC" <<EOF
@${SCOPE}:registry=${REGISTRY}
//npm.pkg.github.com/:_authToken=${TOKEN}
EOF

echo "Publishing ${NAME}@${VERSION} (tag: ${TAG}) to ${REGISTRY}"

pnpm build

jq --arg name "$NAME" --arg version "$VERSION" --arg registry "$REGISTRY" --arg repo "$REPO_URL" \
  '.name = $name | .version = $version | .publishConfig = {registry: $registry} | .repository = {type: "git", url: $repo}' \
  package.json.bak > package.json

npm publish --userconfig "$TMP_NPMRC" --tag "$TAG" --ignore-scripts

cat <<EOF

Published ${NAME}@${VERSION}

To install in a consumer app, add to its .npmrc:
  @${SCOPE}:registry=${REGISTRY}
  //npm.pkg.github.com/:_authToken=\${GITHUB_TOKEN}   # token with read:packages
then:
  pnpm add ${NAME}@${TAG} @aparajita/capacitor-secure-storage
EOF
