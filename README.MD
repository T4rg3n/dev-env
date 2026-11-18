# my-dev-env

Personal Fedora setup scripts for my Framework laptop. 

Run `./setup.sh` to restore the full environment from scratch. Each script is idempotent and safe to re-run.

## What it does

**System (`system/`)**

- DNF packages and repos (GitHub CLI, VS Code, Tailscale official repo [Fedora’s package lags], btop, fingerprint auth, powertop, tuned). `tlp` is not installed: it conflicts with `tuned`. `akmod-evdi` is not in the Fedora repos; evdi comes from the DisplayLink RPM via DKMS.
- Deep sleep (`mem_sleep_default=deep`)
- `tuned` balanced-battery profile
- NVMe/WiFi runtime autosuspend udev rules
- MOK key enrollment for DisplayLink
- Patch + rebuild `evdi` for the running kernel (DisplayLink dock fix after kernel updates)
- DisplayLink dock brightness via `ddcutil` (i2c group, udev rule, `--f23` so evdi adapters are detected)
- GNOME fundraiser notifications disabled
- [fw-fanctrl](https://github.com/TamtamHero/fw-fanctrl) fan control service
- Tuned `intel_lpmd` (Low Power Mode) for Intel i7-1260P (P-Cores = cpu0–7, E-Cores = cpu8–15)
  - Plugged in (`performance` profile) : LPM disabled. All cores active (P + E). No restrictions.
  - On battery (`balanced` profile) :  LPM auto. Switches to E-cores only when util < 20%, exits at > 60%.
  - Eco mode (`power-saver` profile) :  LPM always on. E-cores only (8–15). P-Cores idled at all times via cgroup v2.

**Apps (`apps/`)**

- Flatpak apps from `flatpak-packages.txt` (Flathub, plus KiCad from the Fedora remote)
- [Cursor IDE](https://cursor.com) (DNF)

**Utilities (`utils/`)**

- [Clipboard Indicator](https://github.com/tudmotu/gnome-shell-extension-clipboard-indicator) GNOME extension (clears history on session start)
- [Gear Lever](https://flathub.org/apps/it.mijorus.gearlever) (AppImage manager)
- Shell aliases
- GNOME keyboard shortcuts (Super + E → Files, Super + Shift + S → screenshot snip, Super + D → Show desktop)
- French AZERTY (`fr+azerty`) for the session and the lock screen. A Fedora upgrade resets the system keymap (`localectl`) to `us`, which is what the lock screen uses.
- [Soft Brightness Plus](https://github.com/jkitching/soft-brightness-plus) from the upstream GitHub release (the extensions.gnome.org build does not support GNOME 51)
- Fingerprint: GNOME 51 only allows it for unlock / after sleep. Boot login is password-only on purpose (keyring cannot be unlocked by fingerprint alone).
- [uv](https://docs.astral.sh/uv/) Python toolchain manager
- Python 3.14 via uv
- [Framework Fan Control](https://extensions.gnome.org/extension/7864/framework-fan-control/) GNOME extension
- [Brightness control using ddcutil](https://github.com/daitj/gnome-display-brightness-ddcutil) GNOME extension
- [Framework power LED](https://github.com/T4rg3n/fw-gnome-battery-led) quick-settings toggle. Upstream metadata lags new Shell releases; the installer adds the running major when the build is otherwise current.

**Other**

- Removes Fedora's Firefox homepage (`fedora-bookmarks`)
- `dnf-packages.txt` — reference list of installed packages
- `flatpak-packages.txt` — reference list of installed Flatpak apps (`app-id remote`)

## After setup

1. Reboot to complete MOK enrollment (QWERTY keyboard at the prompt + numeric)
2. Run `source ~/.bashrc`
3. Log out and back in for GNOME extensions to appear (including display brightness)

