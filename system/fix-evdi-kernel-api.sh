#!/bin/bash
#
# fix-evdi-kernel-api.sh
#
# The `displaylink` package bundles the `evdi` DKMS kernel module source, paired
# with its `DisplayLinkManager` userspace daemon. When Fedora pushes a newer
# kernel, evdi often no longer compiles because the upstream DRM atomic API has
# changed. This script detects such breakage, applies the minimal source patch
# needed for the running kernel, rebuilds the module via DKMS, and restarts the
# DisplayLink service so the docking-station displays come back.
#
# Safe and idempotent: re-running it on an already-fixed system is a no-op.
#
# Run after a kernel update if the dock screens stay dark, e.g.:
#     sudo bash system/fix-evdi-kernel-api.sh

set -e

KVER="$(uname -r)"

# ── Locate the evdi DKMS source tree(s) ───────────────────────────────────────
shopt -s nullglob
SRC_DIRS=(/usr/src/evdi-*)
if [ "${#SRC_DIRS[@]}" -eq 0 ]; then
    echo "No evdi DKMS source found under /usr/src/evdi-*."
    echo "Install the displaylink package (or akmod-evdi) first."
    exit 1
fi

# ── Patch: rename drm_atomic_state -> drm_atomic_commit ───────────────────────
# Around Linux 6.14+ the DRM atomic helpers renamed `struct drm_atomic_state`
# to `struct drm_atomic_commit` (and drm_atomic_state_{alloc,clear,put} to
# drm_atomic_commit_{...}). evdi 1.14.x predates this and won't compile. The
# rename is a pure type change, semantically identical, so a sed is sufficient.
patch_dir() {
    local d="$1" f
    for f in "$d"/evdi_modeset.c "$d"/evdi_fb.c; do
        [ -f "$f" ] || continue
        if grep -q 'drm_atomic_state' "$f"; then
            echo "Patching $f (drm_atomic_state -> drm_atomic_commit)"
            # Back up the pristine file once, only while it is still unpatched.
            [ -f "$f.orig" ] || cp -n "$f" "$f.orig"
            sed -i 's/drm_atomic_state/drm_atomic_commit/g' "$f"
        fi
    done
}

for d in "${SRC_DIRS[@]}"; do
    patch_dir "$d"
done

# ── (Re)build the module for the running kernel ───────────────────────────────
# `dkms install` is a no-op if the module is already built for this kernel,
# otherwise it builds using the (now patched) source.
for d in "${SRC_DIRS[@]}"; do
    modver="$(basename "$d" | sed 's/^evdi-//')"
    if dkms status -m evdi -v "$modver" -k "$KVER" 2>/dev/null | grep -q installed; then
        echo "evdi/$modver already built for $KVER."
    else
        echo "Building evdi/$modver for kernel $KVER ..."
        dkms install "evdi/$modver" -k "$KVER" --force
    fi
done

# ── Load the module and restart the DisplayLink daemon ────────────────────────
modprobe evdi || true
systemctl restart displaylink-driver.service

# ── Report ───────────────────────────────────────────────────────────────────
sleep 3
echo ""
echo "evdi loaded:        $(lsmod | grep -q '^evdi ' && echo yes || echo NO)"
echo "displaylink service: $(systemctl is-active displaylink-driver.service)"
echo "Dock displays:"
for c in /sys/class/drm/card*-*/status; do
    [ "$(cat "$c" 2>/dev/null)" = "connected" ] && echo "  $c: connected"
done
echo ""
echo "If the dock screens are still dark, re-plug the dock or re-run this script."
