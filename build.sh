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

# Build zip with best available tool.
if command -v zip >/dev/null 2>&1; then
  (
    cd "$STAGING_ROOT"
    zip -rq "../$PACKAGE_NAME" "$MODULE_NAME"
  )
elif command -v powershell.exe >/dev/null 2>&1; then
  powershell.exe -NoProfile -NonInteractive -Command \
    "Set-Location '${STAGING_ROOT}'; Compress-Archive -Path '${MODULE_NAME}' -DestinationPath '../${PACKAGE_NAME}' -Force" >/dev/null
elif command -v python >/dev/null 2>&1; then
  python - <<'PY'
import os, zipfile
module='samedaycourier'
staging=os.path.join('.build', module)
package=f'{module}.zip'
with zipfile.ZipFile(package, 'w', zipfile.ZIP_DEFLATED) as zf:
    for root, dirs, files in os.walk(staging):
        rel_root=os.path.relpath(root, '.build')
        if not files and not dirs:
            zf.writestr(rel_root.rstrip('/') + '/', '')
            continue
        for f in files:
            p=os.path.join(root, f)
            arc=os.path.join(rel_root, f).replace('\\', '/')
            zf.write(p, arc)
PY
else
  echo "Error: unable to create ${PACKAGE_NAME}. Install one of: zip, PowerShell, or python." >&2
  rm -rf "$STAGING_ROOT"
  exit 1
fi

# Quick integrity checks for PrestaShop module upload expectations.
if command -v python >/dev/null 2>&1; then
  python - <<'PY'
import sys, zipfile
package='samedaycourier.zip'
module='samedaycourier/'
entry='samedaycourier/samedaycourier.php'
with zipfile.ZipFile(package, 'r') as zf:
    names=set(zf.namelist())
if entry not in names:
    print(f'Missing {entry} in {package}', file=sys.stderr)
    sys.exit(1)
# Guard against wrong root folders like .build/samedaycourier
for name in names:
    if name.startswith('.build/') or name.startswith('./'):
        print(f'Invalid archive root entry: {name}', file=sys.stderr)
        sys.exit(1)
if not any(name.startswith(module) for name in names):
    print(f'Archive does not contain top-level {module}', file=sys.stderr)
    sys.exit(1)
PY
elif command -v unzip >/dev/null 2>&1; then
  unzip -l "$PACKAGE_NAME" | grep -q "${MODULE_NAME}/samedaycourier.php"
else
  echo "Warning: cannot validate archive contents automatically (missing unzip and python)." >&2
fi

rm -rf "$STAGING_ROOT"

echo "Built package: ${PACKAGE_NAME}"
