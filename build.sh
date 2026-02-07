#!/bin/sh
set -eu

MODULE_NAME="samedaycourier"
PACKAGE_NAME="${MODULE_NAME}.zip"
STAGING_ROOT=".build"
STAGING_DIR="${STAGING_ROOT}/${MODULE_NAME}"

rm -rf "$PACKAGE_NAME" "$STAGING_ROOT"
mkdir -p "$STAGING_DIR"

# Copy repository content into staging without requiring rsync (Windows Git Bash friendly).
for entry in ./* ./.??*; do
  base="$(basename "$entry")"

  case "$base" in
    .|..|.git|.github|.build|${PACKAGE_NAME}|config.xml)
      continue
      ;;
  esac

  cp -R "$entry" "$STAGING_DIR/"
done

# Remove runtime logs from distributable package, if any were copied.
find "$STAGING_DIR/log" -type f -name '*.log' -delete 2>/dev/null || true

(
  cd "$STAGING_ROOT"
  zip -rq "../$PACKAGE_NAME" "$MODULE_NAME"
)

# Quick integrity checks for PrestaShop module upload expectations.
unzip -l "$PACKAGE_NAME" | grep -q "${MODULE_NAME}/samedaycourier.php"

rm -rf "$STAGING_ROOT"

echo "Built package: ${PACKAGE_NAME}"
