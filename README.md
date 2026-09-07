# ⚡ amd-boost-toggle

> A lightweight, set-and-forget utility to toggle AMD CPU Boost on Linux for cooler thermals, quieter fans, and on-demand gaming performance.

## Features
- **Persistent Default:** Boost is disabled at system boot via `systemd-tmpfiles`.
- **Zero-Password Switching:** Custom Polkit rule allows instant profile changes without `sudo`.
- **Desktop Integration:** Installs a `.desktop` shortcut with native desktop notifications.
- **Zero Daemon Overhead:** Modifies `/sys/devices/system/cpu/cpufreq/boost` directly.

## Quick Install
bash
chmod +x setup-cpu-toggle.sh
./setup-cpu-toggle.sh


## Usage
- **GUI:** Search for "Toggle CPU Boost" in your application menu or pin it to your panel.
- **CLI:** Run `~/.local/bin/toggle-cpu-boost`
