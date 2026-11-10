#!/bin/bash
# Fix for Razer Naga Trinity middle click not working after Synapse 4 update
# See: https://github.com/openrazer/openrazer/issues/2507

if [ "$EUID" -ne 0 ]; then
    echo "ERROR: This script must be run with sudo to edit openrazer files."
    echo "Usage: sudo bash $0"
    exit 1
fi

MOUSE_PY=$(find /usr/lib/python3*/site-packages/openrazer_daemon/hardware/mouse.py 2>/dev/null | head -1)

if [ -z "$MOUSE_PY" ]; then
    echo "ERROR: Could not find openrazer mouse.py"
    exit 1
fi

echo "Found: $MOUSE_PY"

if grep -q "DRIVER_MODE = True" "$MOUSE_PY"; then
    echo "DRIVER_MODE = True already set, restarting daemon..."
else
    echo "Adding DRIVER_MODE = True to RazerNagaTrinity class..."
    sed -i 's/    DEDICATED_MACRO_KEYS = True/    DEDICATED_MACRO_KEYS = True\n    DRIVER_MODE = True/' "$MOUSE_PY"
    echo "Done."
fi

# Safely restart the daemon for the invoking user if running under sudo
if [ -n "$SUDO_USER" ]; then
    echo "Restarting openrazer-daemon for user $SUDO_USER..."
    sudo -u "$SUDO_USER" systemctl --user restart openrazer-daemon 2>/dev/null || true
else
    echo "Restarting openrazer-daemon..."
    systemctl --user restart openrazer-daemon 2>/dev/null || true
fi
echo "All done. Middle click should work now."
