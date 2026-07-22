#!/bin/bash
set -e

echo "=== decklab Installer ==="
echo ""

# Copy modprobe blacklist
echo "Installing kernel module blacklist..."
sudo cp config/disable-qualcomm-bt.conf /etc/modprobe.d/
echo ""

# Clean BT rfkill live and persistent state
echo "Cleaning Bluetooth rfkill state..."
sudo rfkill unblock bluetooth
for f in /var/lib/systemd/rfkill/*bluetooth*; do
  echo 1 | sudo tee "$f" > /dev/null
done
echo ""

echo "=== Done ==="
echo "Reboot to apply: sudo systemctl reboot"
echo ""
echo "To verify after reboot:"
echo "  bluetoothctl list"
echo "  # Should show only one controller (your USB adapter)"
echo ""
echo "To uninstall:"
echo "  ./uninstall.sh"
