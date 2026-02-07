# Sameday Courier

If your are facing some issues when working with our solution our you want to leave us a feedback, please don't hesitate to contact us at plugineasybox@sameday.ro !

## PrestaShop 9.0.1 installation (important)

Do **not** upload the Git repository source ZIP directly (for example, the ZIP downloaded from GitHub's **Code → Download ZIP**).

PrestaShop expects a module package ZIP whose top-level directory is the module technical name (`samedaycourier/`).
A source ZIP from this repository is wrapped in a repository folder name, so PrestaShop may reject it as:

> "This file does not seem to be a valid module zip"

### Correct install flow

1. Download/clone this repository.
2. Build the distributable module archive:

```bash
./build.sh
```

> On Windows (Git Bash), this script now works without `rsync`.

3. Upload the generated file:

```text
samedaycourier.zip
```

in **Back Office → Modules → Module Manager → Upload a module**.

### Quick package validation

You can validate the generated archive structure with:

```bash
unzip -l samedaycourier.zip | head
```

It must contain a top-level `samedaycourier/` folder and `samedaycourier/samedaycourier.php`.
