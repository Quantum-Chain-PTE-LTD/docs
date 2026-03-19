#!/usr/bin/env bash
set -euo pipefail

# Deploy Mintlify docs to S3 + CloudFront
# Usage: ./scripts/deploy-docs.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOCS_DIR="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="/tmp/docs-build"
PORT=4444

S3_BUCKET="${DOCS_S3_BUCKET:-quantum-chain-prod-docs}"
CF_DISTRIBUTION="${DOCS_CF_DISTRIBUTION_ID:-}"

echo "==> Starting Mintlify dev server for pre-rendering..."
cd "$DOCS_DIR"
npx mintlify dev --port "$PORT" &
DEV_PID=$!

cleanup() {
  echo "==> Cleaning up..."
  kill "$DEV_PID" 2>/dev/null || true
  wait "$DEV_PID" 2>/dev/null || true
}
trap cleanup EXIT

# Wait for dev server to be ready
echo "==> Waiting for dev server on port $PORT..."
for i in $(seq 1 60); do
  if curl -s -o /dev/null -w '' "http://localhost:$PORT/" 2>/dev/null; then
    echo "    Server ready after ${i}s"
    break
  fi
  sleep 1
done

# Verify server is responding
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:$PORT/" 2>/dev/null || echo "000")
if [[ "$HTTP_CODE" == "000" ]]; then
  echo "ERROR: Dev server failed to start" >&2
  exit 1
fi

echo "==> Mirroring site to $BUILD_DIR..."
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

wget \
  --mirror \
  --convert-links \
  --adjust-extension \
  --page-requisites \
  --no-parent \
  --directory-prefix="$BUILD_DIR" \
  --quiet \
  "http://localhost:$PORT/" 2>/dev/null || true

# Move from localhost:PORT/ subdirectory to root
if [[ -d "$BUILD_DIR/localhost:$PORT" ]]; then
  mv "$BUILD_DIR/localhost:$PORT"/* "$BUILD_DIR/"
  rmdir "$BUILD_DIR/localhost:$PORT"
fi

PAGE_COUNT=$(find "$BUILD_DIR" -name "*.html" | wc -l)
echo "    Captured $PAGE_COUNT pages"

if [[ "$PAGE_COUNT" -lt 10 ]]; then
  echo "ERROR: Too few pages captured ($PAGE_COUNT). Build may have failed." >&2
  exit 1
fi

echo "==> Uploading to s3://$S3_BUCKET/..."
aws s3 sync "$BUILD_DIR/" "s3://$S3_BUCKET/" \
  --delete \
  --cache-control "public, max-age=3600" \
  --exclude "*.html" \
  --quiet

# HTML files with shorter cache
aws s3 sync "$BUILD_DIR/" "s3://$S3_BUCKET/" \
  --delete \
  --cache-control "public, max-age=300" \
  --include "*.html" \
  --exclude "*" \
  --content-type "text/html" \
  --quiet

if [[ -n "$CF_DISTRIBUTION" ]]; then
  echo "==> Invalidating CloudFront cache..."
  aws cloudfront create-invalidation \
    --distribution-id "$CF_DISTRIBUTION" \
    --paths "/*" \
    --query 'Invalidation.Id' \
    --output text
fi

echo "==> Done! $PAGE_COUNT pages deployed."
