#!/bin/sh
set -eu

MODULE_NAME="samedaycourier"
PACKAGE_NAME="${MODULE_NAME}.zip"
STAGING_DIR=".build/${MODULE_NAME}"

rm -rf "$PACKAGE_NAME" .build
mkdir -p "$STAGING_DIR"

# Build the distributable module tree under .build/samedaycourier
rsync -a \
  --exclude '.git/' \
  --exclude '.github/' \
  --exclude '.build/' \
  --exclude 'samedaycourier.zip' \
  --exclude '*.log' \
  --exclude 'config.xml' \
  ./ "$STAGING_DIR/"

(
  cd .build
  zip -rq "../$PACKAGE_NAME" "$MODULE_NAME"
)

# Quick integrity checks for PrestaShop module upload expectations
unzip -l "$PACKAGE_NAME" | grep -q "${MODULE_NAME}/samedaycourier.php"

rm -rf .build
