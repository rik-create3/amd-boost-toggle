#!/usr/bin/env bash
set -euo pipefail

echo "==> Setting up AMD CPU Boost Toggle..."

# 1. Ensure Boost is OFF by default on system boot
echo 'w /sys/devices/system/cpu/cpufreq/boost - - - - 0' | sudo tee /etc/tmpfiles.d/disable-boost.conf > /dev/null
sudo systemd-tmpfiles --create /etc/tmpfiles.d/disable-boost.conf

# 2. Add Polkit rule for passwordless toggle execution
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
mkdir -p "$HOME/.local/bin"
cat << 'TOGGLE' > "$HOME/.local/bin/toggle-cpu-boost"
#!/usr/bin/env bash
BOOST_FILE="/sys/devices/system/cpu/cpufreq/boost"
CPU0_FREQ="/sys/devices/system/cpu/cpu0/cpufreq"

if [ ! -f "$BOOST_FILE" ]; then
    notify-send -u critical "CPU Boost Error" "Boost controller not found on this hardware."
    exit 1
fi

# Helper function to read sysfs kHz and convert to GHz
get_ghz() {
    local file="$1"
    if [ -f "$file" ]; then
        awk '{printf "%.2f GHz", $1/1000000}' "$file"
    else
        echo "N/A"
    fi
}

CURRENT=$(cat "$BOOST_FILE")

if [ "$CURRENT" -eq 1 ]; then
    pkexec sh -c "echo 0 > $BOOST_FILE"
    MIN_F=$(get_ghz "$CPU0_FREQ/scaling_min_freq")
    MAX_F=$(get_ghz "$CPU0_FREQ/scaling_max_freq")
    notify-send -i preferences-system-power -a "Power Profile" \
        "CPU Boost: OFF" \
        "Quiet & Cool Mode\nTarget Range: $MIN_F – $MAX_F (Base Clock Capped)"
else
    pkexec sh -c "echo 1 > $BOOST_FILE"
    MIN_F=$(get_ghz "$CPU0_FREQ/scaling_min_freq")
    MAX_F=$(get_ghz "$CPU0_FREQ/scaling_max_freq")
    notify-send -i speed-meter -a "Power Profile" \
        "CPU Boost: ON" \
        "High Performance Mode\nActive Range: $MIN_F – $MAX_F (Full Turbo)"
fi
TOGGLE
chmod +x "$HOME/.local/bin/toggle-cpu-boost"

# 4. Create the desktop launcher
mkdir -p "$HOME/.local/share/applications"
cat << 'DESKTOP' > "$HOME/.local/share/applications/cpu-toggle.desktop"
[Desktop Entry]
Name=Toggle CPU Boost
Comment=Switch AMD CPU Boost between Quiet and Performance
Exec=/bin/bash -c "$HOME/.local/bin/toggle-cpu-boost"
Icon=speed-meter
Terminal=false
Type=Application
Categories=System;Settings;
DESKTOP

# 5. Clean up obsolete separate launchers if they exist
rm -f "$HOME/.local/share/applications/cpu-quiet.desktop" "$HOME/.local/share/applications/cpu-boost.desktop"

echo "==> Installation complete! 'Toggle CPU Boost' is ready to use."
