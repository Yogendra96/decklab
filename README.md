# decklab

Disable Steam Deck's built-in Bluetooth so a USB Bluetooth adapter becomes the default.

## The Problem

Steam Deck has two Bluetooth adapters:
- **Built-in** (Qualcomm/Broadcom UART) — soldered to the motherboard
- **USB** (your TP-Link, ASUS, etc.)

The built-in adapter often registers as the system default. Most Bluetooth apps (including KDE's) only talk to the default adapter, and USB enumeration order is unpredictable. rfkill manipulation corrupts bluetoothd (marks all adapters `off-blocked`).

## The Solution

One file, one line: **blacklist the UART Bluetooth kernel driver.**

```bash
echo 'blacklist hci_uart' | sudo tee /etc/modprobe.d/disable-qualcomm-bt.conf
```

The built-in BT uses `hci_uart.ko`. USB adapters use `btusb.ko` (separate driver, unaffected). Without the driver, the kernel never creates the built-in adapter — your USB adapter is the only one, always the default.

**No scripts, no services, no MAC addresses, no boot ordering.**

## Reversible

```bash
sudo rm /etc/modprobe.d/disable-qualcomm-bt.conf
sudo modprobe hci_uart    # or reboot
```

## Files

```
decklab/
├── README.md
├── install.sh
├── uninstall.sh
└── config/
    └── disable-qualcomm-bt.conf
```

## License

MIT
