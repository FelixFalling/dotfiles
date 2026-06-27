#!/bin/bash
# Fix for Razer Naga Trinity middle click not working after Synapse 4 update
# See: https://github.com/openrazer/openrazer/issues/2507
#
# Run with sudo: sudo bash ~/fix-razer-middle-click.sh

MOUSE_PY=$(find /usr/lib/python3*/site-packages/openrazer_daemon/hardware/mouse.py 2>/dev/null | head -1)

if [ -z "$MOUSE_PY" ]; then
    echo "ERROR: Could not find openrazer mouse.py"
    exit 1
fi

echo "Found: $MOUSE_PY"

if grep -q "DRIVER_MODE = True" "$MOUSE_PY"; then
    echo "DRIVER_MODE = True already set, just restarting daemon..."
else
    echo "Adding DRIVER_MODE = True to RazerNagaTrinity class..."
    sed -i 's/    DEDICATED_MACRO_KEYS = True/    DEDICATED_MACRO_KEYS = True\n    DRIVER_MODE = True/' "$MOUSE_PY"
    echo "Done."
fi

echo "Restarting openrazer-daemon..."
systemctl --user restart openrazer-daemon
echo "All done. Middle click should work now."
