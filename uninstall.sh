#!/bin/bash
set -e

echo "=== decklab Uninstaller ==="

# Remove modprobe blacklist
echo "Removing kernel module blacklist..."
sudo rm -f /etc/modprobe.d/disable-qualcomm-bt.conf

# Load the module back
echo "Reloading UART Bluetooth driver..."
sudo modprobe hci_uart 2>/dev/null || echo "(will load on next boot automatically)"

echo ""
echo "=== Done ==="
echo "Built-in Bluetooth will reappear after reboot."
echo "You can also run: sudo modprobe hci_uart"
