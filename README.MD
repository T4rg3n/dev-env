# my-dev-env

Personal Fedora setup scripts for my Framework laptop. 

Run `./setup.sh` to restore the full environment from scratch. Each script is idempotent and safe to re-run.

## What it does

**System (`system/`)**

- DNF packages and repos (GitHub CLI, VS Code, btop, fingerprint auth, DisplayLink/EVDI, TLP, powertop, tuned)
- Deep sleep (`mem_sleep_default=deep`)
- `tuned` balanced-battery profile
- NVMe/WiFi runtime autosuspend udev rules
- MOK key enrollment for DisplayLink
- GNOME fundraiser notifications disabled
- [fw-fanctrl](https://github.com/TamtamHero/fw-fanctrl) fan control service
- Tuned `intel_lpmd` (Low Power Mode) for Intel i7-1260P (P-Cores = cpu0–7, E-Cores = cpu8–15)
  - Plugged in (`performance` profile) : LPM disabled. All cores active (P + E). No restrictions.
  - On battery (`balanced` profile) :  LPM auto. Switches to E-cores only when util < 20%, exits at > 60%.
  - Eco mode (`power-saver` profile) :  LPM always on. E-cores only (8–15). P-Cores idled at all times via cgroup v2.

**Utilities (`utils/`)**

- [Clipboard Indicator](https://github.com/tudmotu/gnome-shell-extension-clipboard-indicator) GNOME extension
- [Gear Lever](https://flathub.org/apps/it.mijorus.gearlever) (AppImage manager)
- Shell aliases
- GNOME keyboard shortcuts (Super + E → Files, Super + Shift + S → screenshot snip, Super + D → Show desktop)
- [uv](https://docs.astral.sh/uv/) Python toolchain manager
- Python 3.14 via uv
- [Framework Fan Control](https://extensions.gnome.org/extension/7864/framework-fan-control/) GNOME extension

**Other**

- Removes Fedora's Firefox homepage (`fedora-bookmarks`)
- `dnf-packages.txt` — reference list of installed packages

## After setup

1. Reboot to complete MOK enrollment (QWERTY keyboard at the prompt + numeric)
2. Run `source ~/.bashrc`
3. Log out and back in for GNOME extensions to appear

