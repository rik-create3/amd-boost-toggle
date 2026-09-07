#!/usr/bin/env bash
set -euo pipefail

echo "==> Setting up AMD CPU Boost Toggle..."

# --- Dependency checks -------------------------------------------------
command -v notify-send >/dev/null 2>&1 || {
    echo "Error: notify-send not found. Install libnotify (see README) and re-run this script."
    exit 1
}
command -v pkexec >/dev/null 2>&1 || {
    echo "Error: pkexec not found. Install polkit (see README) and re-run this script."
    exit 1
}
command -v sudo >/dev/null 2>&1 || {
    echo "Error: sudo not found. Install sudo (see README) and re-run this script."
    exit 1
}

# --- Hardware check ------------------------------------------------------
BOOST_FILE="/sys/devices/system/cpu/cpufreq/boost"
if [ ! -f "$BOOST_FILE" ]; then
    echo "Error: $BOOST_FILE not found."
    echo "This script requires an AMD CPU using the acpi-cpufreq or amd-pstate driver."
    exit 1
fi

# 1. Ensure Boost is OFF by default on system boot
echo "==> Configuring default boost-off state on boot..."
echo 'w /sys/devices/system/cpu/cpufreq/boost - - - - 0' | sudo tee /etc/tmpfiles.d/disable-boost.conf > /dev/null
sudo systemd-tmpfiles --create /etc/tmpfiles.d/disable-boost.conf

# 2. Add Polkit rule for passwordless toggle execution
echo "==> Installing polkit rule..."
sudo tee /etc/polkit-1/rules.d/51-cpu-boost.rules > /dev/null << 'POLKIT'
polkit.addRule(function(action, subject) {
    if (action.id == "org.freedesktop.policykit.exec" &&
        action.lookup("command_line").indexOf("/sys/devices/system/cpu/cpufreq/boost") !== -1 &&
        subject.isInGroup("wheel")) {
        return polkit.Result.YES;
    }
});
POLKIT

# 3. Create the toggle script
echo "==> Installing toggle-cpu-boost..."
mkdir -p "$HOME/.local/bin"
cat << 'TOGGLE' > "$HOME/.local/bin/toggle-cpu-boost"
#!/usr/bin/env bash
BOOST_FILE="/sys/devices/system/cpu/cpufreq/boost"
FREQ_DIR="/sys/devices/system/cpu/cpu0/cpufreq"

command -v notify-send >/dev/null 2>&1 || { echo "Error: notify-send not found. Install libnotify."; exit 1; }
command -v pkexec >/dev/null 2>&1 || { echo "Error: pkexec not found. Install polkit."; exit 1; }

if [ ! -f "$BOOST_FILE" ]; then
    notify-send -u critical "CPU Boost Error" "Boost controller not found. Requires an AMD CPU with acpi-cpufreq or amd-pstate."
    exit 1
fi

get_max_freq() {
    if [ -f "$FREQ_DIR/cpuinfo_max_freq" ]; then
        awk "BEGIN { printf \"%.2f\", $(cat "$FREQ_DIR/cpuinfo_max_freq") / 1000000 }"
    else
        echo "?"
    fi
}

CURRENT=$(cat "$BOOST_FILE")

if [ "$CURRENT" -eq 1 ]; then
    NEW_STATE=0
    LABEL="CPU Boost: OFF"
    ICON="preferences-system-power"
    MODE_MSG="Switched to Quiet & Cool Mode"
else
    NEW_STATE=1
    LABEL="CPU Boost: ON"
    ICON="speed-meter"
    MODE_MSG="Switched to High Performance Mode"
fi

if ! pkexec sh -c "echo $NEW_STATE > $BOOST_FILE" 2>/tmp/cpu-boost-err; then
    ERR_MSG="pkexec failed. If no password prompt appeared, you likely have no polkit agent running."
    notify-send -u critical -a "Power Profile" "CPU Boost Error" "$ERR_MSG"
    echo "Error: $ERR_MSG" >&2
    exit 1
fi

# Read frequency AFTER the toggle applies
sleep 0.2
MAX_GHZ=$(get_max_freq)

notify-send -i "$ICON" -a "Power Profile" "$LABEL" "$MODE_MSG (Max ${MAX_GHZ} GHz)"
TOGGLE
chmod +x "$HOME/.local/bin/toggle-cpu-boost"

# 4. Create the desktop launcher
echo "==> Installing app shortcut..."
mkdir -p "$HOME/.local/share/applications"
cat << 'DESKTOP' > "$HOME/.local/share/applications/cpu-toggle.desktop"
[Desktop Entry]
Name=Toggle CPU Boost
Comment=Switch AMD CPU Boost between Quiet and Performance
Exec=/bin/bash -c "$HOME/.local/bin/toggle-cpu-boost"
Icon=preferences-system-power
Terminal=false
Type=Application
Categories=System;Settings;
DESKTOP

# Refresh desktop database so the shortcut shows up immediately (if available)
if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true
fi

# 5. Clean up obsolete separate launchers if they exist
rm -f "$HOME/.local/share/applications/cpu-quiet.desktop" "$HOME/.local/share/applications/cpu-boost.desktop"

echo "==> Installation complete! 'Toggle CPU Boost' is ready to use."
echo "    Run it from your app launcher, or directly via: $HOME/.local/bin/toggle-cpu-boost"
