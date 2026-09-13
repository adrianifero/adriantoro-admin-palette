#!/usr/bin/env bash
# Build a WordPress.org-compatible zip: top-level folder must be adriantoro-admin-palette.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

VERSION="$(grep -E '^\s*\* Version:' adriantoro-admin-palette.php | head -1 | awk '{print $3}')"
SLUG="adriantoro-admin-palette"
STAGE="$(mktemp -d)"
OUT="${ROOT}/dist/${SLUG}-${VERSION}.zip"
SUBMISSION="${ROOT}/submission/${SLUG}-${VERSION}.zip"
rm -f "$OUT" "$SUBMISSION"

mkdir -p "${ROOT}/dist" "${ROOT}/submission" \
  "${STAGE}/${SLUG}/includes" \
  "${STAGE}/${SLUG}/assets/css" \
  "${STAGE}/${SLUG}/assets/js"

cp adriantoro-admin-palette.php readme.txt "${STAGE}/${SLUG}/"
cp includes/*.php "${STAGE}/${SLUG}/includes/"
cp assets/css/*.css "${STAGE}/${SLUG}/assets/css/"
cp assets/js/*.js "${STAGE}/${SLUG}/assets/js/"

(
  cd "$STAGE"
  zip -r "$OUT" "$SLUG" -x '*/.DS_Store' '*/.git/*'
)

cp "$OUT" "$SUBMISSION"
rm -rf "$STAGE"

if ! unzip -p "$OUT" "${SLUG}/assets/js/color-panel.js" | grep -q 'atacColorPanel'; then
	echo "ERROR: zip JS missing color panel" >&2
	exit 1
fi

if ! unzip -p "$OUT" "${SLUG}/includes/class-brand-colors.php" | grep -q 'atac_brand_colors'; then
	echo "ERROR: zip PHP missing brand colors module" >&2
	exit 1
fi

if ! unzip -p "$OUT" "${SLUG}/adriantoro-admin-palette.php" | grep -q 'Plugin Name: AdrianToro Admin Palette'; then
	echo "ERROR: zip main file missing AdrianToro Admin Palette header" >&2
	exit 1
fi

echo "Wrote $OUT"
echo "Submission copy: $SUBMISSION"
unzip -l "$OUT"
