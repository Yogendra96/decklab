#!/bin/bash
set -e

echo "=== Steam Deck Dock Setup Installer ==="

# Check if MAC addresses are configured
SCRIPT="scripts/disable-hci0"
if grep -q "XX:XX:XX:XX:XX:XX" "$SCRIPT"; then
  echo ""
  echo "ERROR: You must edit scripts/disable-hci0 first with your Bluetooth MAC addresses."
  echo "Find them with: bluetoothctl list"
  echo ""
  exit 1
fi

# Make rootfs writable
echo "Disabling SteamOS read-only lock..."
sudo steamos-readonly disable

# Copy systemd service
echo "Installing systemd service..."
sudo cp systemd/disable-hci0.service /etc/systemd/system/

# Copy script
echo "Installing script..."
mkdir -p /home/deck/.local/bin
cp "$SCRIPT" /home/deck/.local/bin/disable-hci0
chmod +x /home/deck/.local/bin/disable-hci0

# Enable and start
echo "Enabling and starting service..."
sudo systemctl daemon-reload
sudo systemctl enable disable-hci0.service
sudo systemctl start disable-hci0.service

# Verify
echo ""
echo "=== Verification ==="
systemctl status disable-hci0.service --no-pager | head -5
echo ""
echo "Bluetooth controllers:"
bluetoothctl list
echo ""
echo "Done. Reboot to confirm: sudo systemctl reboot"
