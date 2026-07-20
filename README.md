# Steam Deck Dock Setup

Hardware configuration, Bluetooth management, and USB topology documentation for a Steam Deck driving two docks.

## Hardware

| Device | Role |
|---|---|
| Steam Deck (16GB, SteamOS 3.8) | Host |
| Portrtonics Dock | Always-on hub for keyboard/mouse/BT (bus-powered, no PSU needed) |
| Wavlink UHP3426 6-in-1 Dock | Desk dock: HDMI 2.1 (4K@144Hz), Gigabit Ethernet, SD reader, 3x USB 3.2 Gen2 (10Gbps), 100W PD |
| TP-Link BT USB Adapter (Realtek RTL8761B) | Primary Bluetooth (hci1) |
| UGREEN 2.4GHz Receiver | Keyboard |
| Xenta 2.4GHz Wireless Device | Mouse |

## USB Topology

```
                    Steam Deck USB-C
                         │
               ┌─────────┴──────────┐
               │                    │
          Portrtonics          Wavlink UHP3426
       (bus-powered,        (needs 19V PSU)
        always on)              │
          │                ┌────┴──────────┐
     ┌────┴────┐          │ HDMI 2.1        │
     │ TP-Link │          │ Gigabit Ethernet│
     │ UGREEN  │          │ SD Card Reader  │
     │ Xenta   │          │ 3x USB 3.2 Gen2 │
     └─────────┘          │ PD 100W IN      │
                          └─────────────────┘
```

## The Problem

### 1. Boot Hang with TP-Link in Dock

Plugging the TP-Link BT adapter into the Portrtonics dock (Genesys Logic hub) causes a 90-second USB stall at boot:

```
hub_ext_port_status failed (err = -71)
```

The TP-Link connected directly to the Steam Deck boots clean (~14.5s). In the dock, it hangs at ~31.5s+. Root cause: USB enumeration failure between the Realtek chip and the Genesys hub during boot.

**Workaround:** TP-Link stays in the Portrtonics but the Portrtonics plugs into the Wavlink's USB-A port, not directly into the Deck. The Wavlink is only connected when at the desk.

### 2. Qualcomm Bluetooth (hci0) Conflicts

The Deck's built-in Qualcomm BT (hci0) interferes with the TP-Link (hci1). The systemd service in this repo disables hci0 at boot via BlueZ.

### 3. Wavlink Needs External Power

The Wavlink dock's hub chip is `Self Powered` (reports 0mA from USB bus). It requires its 19V PSU for any downstream port to function — even USB keyboard/mouse. This is by design: HDMI 2.1 + 10Gbps USB + PD charging need ~15-20W, far beyond the Deck's ~4.5W bus power budget.

## Solution

### Bluetooth: Systemd Service

Disables the built-in Qualcomm BT and enables the TP-Link at every boot:

```
/etc/systemd/system/disable-hci0.service
    └── /home/deck/.local/bin/disable-hci0
```

The script:
1. Waits for bluetoothd to be ready
2. Selects hci0 (Qualcomm) by MAC → powers it off
3. Selects hci1 (TP-Link) by MAC → powers it on, makes discoverable

### Example Device Map

```
hci1 (TP-Link)
  ├── MacBook Pro
  ├── iPad Pro
  ├── Bluetooth Headset
  └── (available for new devices)

hci0 (Qualcomm, built-in)
  └── Powered OFF via systemd service
```

## Prerequisites

SteamOS has a read-only root filesystem by default. Before installing:

```bash
# Make rootfs writable (required for copying to /etc/systemd/system/)
sudo steamos-readonly disable
```

To re-enable read-only after installation:

```bash
sudo steamos-readonly enable
```

## Installation

### 1. Edit MAC Addresses

Edit `scripts/disable-hci0` and replace the placeholder MACs with your hardware's:

```bash
# Find your Bluetooth controller MACs
bluetoothctl list

# Example output:
# Controller XX:XX:XX:XX:XX:XX steamdeck [default]  ← built-in Qualcomm
# Controller YY:YY:YY:YY:YY:YY steamdeck #2          ← TP-Link USB adapter
```

### 2. Install

```bash
# Copy systemd service
sudo cp systemd/disable-hci0.service /etc/systemd/system/

# Copy script
mkdir -p /home/deck/.local/bin
cp scripts/disable-hci0 /home/deck/.local/bin/
chmod +x /home/deck/.local/bin/disable-hci0

# Enable and start
sudo systemctl daemon-reload
sudo systemctl enable disable-hci0.service
sudo systemctl start disable-hci0.service

# Verify
systemctl status disable-hci0.service
```

### One-Command Install

```bash
sudo steamos-readonly disable && \
sudo cp systemd/disable-hci0.service /etc/systemd/system/ && \
mkdir -p /home/deck/.local/bin && \
cp scripts/disable-hci0 /home/deck/.local/bin/ && \
chmod +x /home/deck/.local/bin/disable-hci0 && \
sudo systemctl daemon-reload && \
sudo systemctl enable disable-hci0.service && \
sudo systemctl start disable-hci0.service
```

## Verification

Check Bluetooth status:

```bash
# Both controllers should appear
bluetoothctl list

# hci0 should be off, hci1 should be on and discoverable
bluetoothctl show <HCI0_MAC>  # Powered: no
bluetoothctl show <HCI1_MAC>  # Powered: yes, Discoverable: yes

# Check systemd service
systemctl status disable-hci0.service

# View connected devices
bluetoothctl devices Connected
```

## Tips

### Prevent Battery Degradation While Docked

Enable the 80% charge limit in SteamOS:

```
Settings → Battery → Charge Limit → ON
```

This halts charging at 80% when the Deck is plugged in 24/7, halving long-term battery wear. SteamOS handles pass-through charging — at 100%, the Deck runs directly from the power supply, not the battery.

### rfkill Cleanup (if BT adapters are blocked)

If Bluetooth appears blocked after installation:

```bash
# Check rfkill state
rfkill list bluetooth

# Unblock all Bluetooth adapters
sudo rfkill unblock bluetooth

# Make persistent (all rfkill state files = 0)
sudo bash -c 'for f in /var/lib/systemd/rfkill/*; do echo 0 > "$f"; done'
```

## Files

```
decklab/
├── README.md
├── .gitignore
├── scripts/
│   └── disable-hci0      # Bluetooth toggle script
├── systemd/
│   └── disable-hci0.service  # Systemd oneshot service
└── docs/
    └── topology.md        # ASCII topology diagrams
```

## License

MIT
