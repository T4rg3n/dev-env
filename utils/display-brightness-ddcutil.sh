#!/bin/bash

set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=gnome-extension.sh
source "$DIR/gnome-extension.sh"

UUID="display-brightness-ddcutil@themightydeity.github.com"
EXT_PK=2645
EXT_DIR="$(extension_dir "$UUID")"

GNOME_VERSION="$(gnome_shell_major)"
if [ -z "$GNOME_VERSION" ]; then
    echo "Could not detect GNOME Shell version."
    exit 1
fi
echo "Detected GNOME Shell version: $GNOME_VERSION"

# ddcutil 3 names the laptop panel "BOE::" and tags it "Invalid display".
# Version 59's parser requires a model after the second colon, skips the
# record, and leaves the menu on "Initializing". Re-apply the fix whenever
# an install (or a stamp) drops the unfixed file back in.
patch_ddcutil3() {
    local ext="$1"
    grep -q "invalidRecord" "$ext" && return 0
    python3 - "$ext" << 'PY'
import pathlib, sys
path = pathlib.Path(sys.argv[1])
text = path.read_text()
old = """                if (ddcLine.trim().length === 0) {
                    displayBus = null;
                    displayName = null;
                }

                if (this.busValidate(ddcLine)) {
                    displayBus = ddcLine.split('/dev/i2c-')[1].trim();
                    brightnessLog(this.settings, `ddcutil brief info found bus: ${displayBus}`);
                }

                if (ddcLine.indexOf('Monitor:') !== -1) {
                    displayName = ddcLine.split('Monitor:')[1].trim().split(':')[1].trim();
                    brightnessLog(this.settings, `ddcutil brief info found name: ${displayName}`);
                }"""
new = """                if (ddcLine.trim().length === 0) {
                    displayBus = null;
                    displayName = null;
                    invalidRecord = false;
                }

                if (ddcLine.includes('Invalid display'))
                    invalidRecord = true;
                if (invalidRecord)
                    continue;

                if (this.busValidate(ddcLine)) {
                    displayBus = ddcLine.split('/dev/i2c-')[1].trim();
                    brightnessLog(this.settings, `ddcutil brief info found bus: ${displayBus}`);
                }

                if (ddcLine.indexOf('Monitor:') !== -1) {
                    const raw = ddcLine.split('Monitor:')[1].trim();
                    const parts = raw.split(':').map(part => part.trim()).filter(part => part.length > 0);
                    displayName = parts.length >= 2 ? parts[1] : (parts[0] || raw);
                    brightnessLog(this.settings, `ddcutil brief info found name: ${displayName}`);
                }"""
if old not in text:
    sys.exit("ddcutil extension parser did not match; not patching")
text = text.replace(
    "            let displayBus;\n            let displayName;\n",
    "            let displayBus;\n            let displayName;\n            let invalidRecord = false;\n",
    1,
)
text = text.replace(old, new, 1)
text = text.replace(
    """        } catch (err) {
            brightnessLog(this.settings, err);
        }
    }

    async addDisplayToPanelIfItIsOn""",
    """        } catch (err) {
            brightnessLog(this.settings, err);
        }
        this.reloadMenuWidgets();
    }

    async addDisplayToPanelIfItIsOn""",
    1,
)
path.write_text(text)
print(f"Patched {path} for ddcutil 3")
PY
}

if extension_supports_shell "$EXT_DIR" "$GNOME_VERSION"; then
    echo "Extension $UUID already supports GNOME $GNOME_VERSION, ensuring it is enabled..."
    patch_ddcutil3 "$EXT_DIR/extension.js"
    fix_extension_perms "$EXT_DIR"
    gnome-extensions enable "$UUID"
    exit 0
fi

VERSION_TAG=$(curl -sf "https://extensions.gnome.org/extension-info/?pk=${EXT_PK}&shell_version=${GNOME_VERSION}" \
    | python3 -c "
import sys, json
data = json.load(sys.stdin)
vm = data.get('shell_version_map', {})
key = '${GNOME_VERSION}'
if key in vm:
    print(vm[key]['pk'])
else:
    sys.exit(1)
" 2>/dev/null) || true

if [ -z "$VERSION_TAG" ]; then
    if [ -f "$EXT_DIR/metadata.json" ]; then
        echo "No upstream release for GNOME $GNOME_VERSION. Marking the installed copy compatible."
        stamp_shell_version "$EXT_DIR" "$GNOME_VERSION"
        patch_ddcutil3 "$EXT_DIR/extension.js"
        fix_extension_perms "$EXT_DIR"
        gnome-extensions enable "$UUID"
        exit 0
    fi
    echo "No extension release found for GNOME Shell $GNOME_VERSION."
    echo "Install manually from: https://extensions.gnome.org/extension/${EXT_PK}/"
    exit 1
fi

echo "Downloading Brightness control using ddcutil (version_tag=${VERSION_TAG})..."
TMPZIP=$(mktemp --suffix=.zip)
trap 'rm -f "$TMPZIP"' EXIT

UUID_ENCODED="${UUID/@/%40}"
curl -sSL --fail -o "$TMPZIP" \
    "https://extensions.gnome.org/download-extension/${UUID_ENCODED}.shell-extension.zip?version_tag=${VERSION_TAG}"

gnome-extensions install --force "$TMPZIP"
patch_ddcutil3 "$EXT_DIR/extension.js"
fix_extension_perms "$EXT_DIR"
gnome-extensions enable "$UUID"

echo "Extension '$UUID' installed and enabled."
echo "Log out and back in (or restart GNOME Shell) for the brightness sliders to appear."
