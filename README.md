# ⚡ amd-boost-toggle

> A lightweight utility to toggle AMD CPU Boost on Linux — cooler thermals and quieter fans by default, full clocks on demand.

![Platform](https://img.shields.io/badge/Platform-Linux-blue?logo=linux)
![Hardware](https://img.shields.io/badge/CPU-AMD%20Ryzen-ED1C24?logo=amd)
![Shell](https://img.shields.io/badge/Shell-Bash-4EAA25?logo=gnu-bash)
![License](https://img.shields.io/badge/License-MIT-green)

---

## The Problem

Modern AMD Ryzen CPUs aggressively boost clock speeds for brief background tasks like web browsing, streaming, or text editing — spiking thermals and fan noise even during light desktop use.

## The Solution

`amd-boost-toggle` gives you one-click control over AMD's hardware boost state via native Linux kernel interfaces — toggled instantly with a desktop shortcut or terminal command.

- **Boost OFF (default):** CPU stays capped at base clock — cooler, quieter, ideal for everyday work.
- **Boost ON:** Full clock ceiling unlocked instantly for gaming, compiling, or rendering.

---

## Features

- **Persistent Default:** Boost is disabled at every system boot via `systemd-tmpfiles`.
- **Passwordless Toggle:** A scoped Polkit rule lets the toggle run without a `sudo` password prompt each time.
- **Desktop Shortcut:** Installs a standard `.desktop` launcher, searchable from your app menu.
- **Live Notifications:** Each toggle shows a notification with the current mode and the CPU's actual max frequency for that state.
- **No Background Process:** Pure sysfs read/write — no daemon, no persistent memory footprint.

---

## Requirements

- AMD CPU exposing `/sys/devices/system/cpu/cpufreq/boost` (`acpi-cpufreq` or `amd-pstate` driver)
- `systemd`
- `libnotify` (`notify-send`)
- `polkit`, with an agent running (built into GNOME, KDE, XFCE, Cinnamon by default)

```bash
# Arch / Manjaro
sudo pacman -S libnotify polkit

# Debian / Ubuntu / Mint
sudo apt install libnotify-bin policykit-1

# Fedora
sudo dnf install libnotify polkit
```

---

## Installation

```bash
git clone https://github.com/rik-create3/amd-boost-toggle.git
cd amd-boost-toggle
chmod +x setup-cpu-toggle.sh
./setup-cpu-toggle.sh
```

Enter your password when prompted to install the system policy files.

---

## Usage

Launch **"Toggle CPU Boost"** from your app menu, or run:

```bash
~/.local/bin/toggle-cpu-boost
```
