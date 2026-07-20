# USB Topology

## Physical Connection Chain

```
                    Steam Deck (USB-C)
                         │
               ┌─────────┴──────────┐
               │                    │
          Portrtonics          Wavlink UHP3426
       (bus-powered,        (needs 19V PSU)
        always on)              │
          │                ┌────┴──────────┐
     ┌────┴────┐          │ HDMI 2.1        │
     │ TP-Link │          │ 4K@144Hz        │
     │ BT hci1 │          │                 │
     │ UGREEN  │          │ Gigabit Ethernet│
     │ KB      │          │ (RTL8153)       │
     │ Xenta   │          │                 │
     │ Mouse   │          │ SD Card Reader  │
     └─────────┘          │ (USB3.0)        │
                          │                 │
                          │ USB-C 3.2 Gen2  │
                          │ (10Gbps)        │
                          │                 │
                          │ 2x USB-A 3.2    │
                          │ Gen2 (10Gbps)   │
                          │                 │
                          │ PD 100W IN      │
                          │ ← 45W-100W PSU  │
                          └─────────────────┘
```

## Live USB Tree (lsusb -t)

```
/:  Bus 001 (USB 2.0 @ 480M) — Wavlink USB2 + Portrtonics
    |__ Port 1: VIA Labs USB2.0 Hub
        |__ Port 3: Genesys Logic Hub
            |__ Port 3: Genesys Logic Hub
                |__ Port 1: TP-Link BT Adapter (btusb, 12M)
                |__ Port 2: UGREEN 2.4G Receiver (usbhid, 12M)
                |__ Port 3: Xenta 2.4G Mouse (usbhid, 12M)
        |__ Port 5: VIA Labs Billboard Device (DP Alt Mode)

/:  Bus 002 (USB 3.0 @ 10Gbps) — Wavlink USB3
    |__ Port 1: VIA Labs USB3.1 Hub
        |__ Port 3: Genesys Logic Hub
            |__ Port 1: Realtek RTL8153 Ethernet (r8152, 5Gbps)
            |__ Port 2: SD Card Reader (usb-storage, 5Gbps)
            |__ Port 3: Genesys USB3.1 Hub (empty ports)
        |__ Port 4: Realtek RTL8153 Ethernet (spare)

/:  Bus 003 (USB 2.0) — Deck internal
    |__ Port 3: Steam Deck Controller

/:  Bus 004 (USB 3.0) — empty
```

## Bluetooth

```
hci0: Qualcomm WCN6855 (built-in)
  Bus:  UART (internal)
  State: OFF (systemd disable-hci0.service)

hci1: TP-Link Bluetooth USB Adapter (Realtek RTL8761B)
  Bus:  USB 1.1 (full-speed)
  State: ON, Discoverable
  Devices:
    ├── MacBook Pro (connected)
    ├── iPad Pro (paired)
    ├── Bluetooth Headset (connected)
    └── (available)
```

## Power

```
45W USB-C PD Charger
  └── Wavlink PD IN (100W rated)
       └── Steam Deck receives ~25-30W (dock consumes ~15-20W internally)

Portrtonics: bus-powered from Wavlink USB-A (5V, ~500mA)
TP-Link: bus-powered from Portrtonics (5V, ~100mA)
UGREEN KB: bus-powered from Portrtonics
Xenta Mouse: bus-powered from Portrtonics
```
