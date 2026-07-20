#!/bin/bash
set -e

echo "=== decklab Uninstaller ==="

# Stop and disable systemd service
echo "Stopping and disabling service..."
sudo systemctl stop disable-hci0.service 2>/dev/null || true
sudo systemctl disable disable-hci0.service 2>/dev/null || true

# Remove systemd service
echo "Removing systemd service..."
sudo rm -f /etc/systemd/system/disable-hci0.service

# Remove script
echo "Removing script..."
rm -f /home/deck/.local/bin/disable-hci0

# Reload systemd
sudo systemctl daemon-reload

# Re-enable built-in Bluetooth (hci0)
echo "Re-enabling built-in Bluetooth..."
bluetoothctl << EOF
power on
quit
EOF

echo ""
echo "=== Done ==="
echo "decklab has been removed."
echo ""
echo "To re-enable SteamOS read-only:"
echo "  sudo steamos-readonly enable"
echo ""
echo "Reboot recommended:"
echo "  sudo systemctl reboot"
