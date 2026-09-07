# ⚡ amd-boost-toggle

> A lightweight, set-and-forget utility to toggle AMD CPU Boost on Linux for cooler thermals, quieter fans, and on-demand gaming performance.

![Platform](https://img.shields.io/badge/Platform-Linux-blue?logo=linux)
![Hardware](https://img.shields.io/badge/CPU-AMD%20Ryzen-ED1C24?logo=amd)
![Shell](https://img.shields.io/badge/Shell-Bash-4EAA25?logo=gnu-bash)
![License](https://img.shields.io/badge/License-MIT-green)

---

## 🛑 The Problem

Modern AMD Ryzen mobile and desktop CPUs aggressively spike clock frequencies and core voltages (often exceeding 1.4V) for brief background tasks like web browsing, streaming, or text editing. 

On laptops, this aggressive boosting causes:
- Sudden thermal spikes (70°C+ during light desktop usage).
- Excessive fan ramping and distracting acoustics.
- Accelerated battery drain.

## 💡 The Solution

`amd-boost-toggle` gives you one-click control over AMD's hardware boost state via native Linux kernel interfaces:
- **Base Clock Mode (Boost OFF):** Keeps your CPU running cool (~45°C–52°C) and completely silent during everyday work, coding, and browsing.
- **Boost Mode (Boost ON):** Unlocks full multi-core and single-core clock ceilings instantly when you are ready to compile or launch a game.

---

## ✨ Features

- **Persistent Default:** Automatically ensures Boost is disabled at system boot via `systemd-tmpfiles`.
- **Zero-Password Switching:** Includes a Polkit security rule to execute state changes seamlessly without entering `sudo` passwords.
- **Native Desktop Integration:** Generates a FreeDesktop `.desktop` entry compatible with KDE Plasma, GNOME, XFCE, and tiling window managers (can be pinned to taskbars or desktops).
- **Instant Visual Feedback:** Displays native desktop notifications indicating the active thermal profile using `notify-send`.
- **Zero Daemon Overhead:** No background daemon or continuous memory footprint; state changes are written directly to `sysfs`.

---

## 📋 Compatibility

- **Hardware:** AMD Ryzen CPUs exposing `/sys/devices/system/cpu/cpufreq/boost`.
- **Operating System:** Any modern Linux distribution utilizing `systemd` and `polkit` (Arch Linux, EndeavourOS, Fedora, Ubuntu, Debian, openSUSE).
- **Desktop Environments:** KDE Plasma, GNOME, Cinnamon, XFCE, Hyprland, Sway, etc.

---

## 🚀 Installation

### Option 1: File Manager (GUI)
You can install this directly without opening a terminal:

1. **Download & Extract:** Download the repository ZIP and extract the folder.
2. **Make Executable:** Right-click `setup-cpu-toggle.sh` ➔ **Properties** ➔ **Permissions** tab ➔ check **"Allow executing file as program"** (or *Executable*).
3. **Run:**
   - **Double-click** `setup-cpu-toggle.sh` and select **"Run in Terminal"** (or "Run").
   - *Alternatively:* Right-click inside the folder, choose **"Open in Terminal"**, and run:
     ```bash
     ./setup-cpu-toggle.sh
     ```
4. Enter your admin password when prompted to install the system policy files.

---

### Option 2: Terminal (CLI)
```bash
git clone [https://github.com/rik-create3/amd-boost-toggle.git](https://github.com/rik-create3/amd-boost-toggle.git)
cd amd-boost-toggle
chmod +x setup-cpu-toggle.sh
./setup-cpu-toggle.sh
