# Tally Controller

**32Thirteen Productions LLC**

macOS app for controlling groups of [ESP32 SmallHD tally bridge](https://github.com/Kunkles/esp32-smallhd-tally-light) units over a local network. Send tally on/off commands to individual monitors or all of them at once via gang mode.

---

## Download

Grab the latest build from the release folder:

| Version | Download |
| :--- | :--- |
| v1.0.0 | [TallyController v1.0.0](TallyController%20v1.0.0/TallyController.app) |

Drag `TallyController.app` to your Applications folder and open it. macOS may ask to allow the app on first launch — go to **System Settings → Privacy & Security** and click **Open Anyway**.

---

## Requirements

- macOS 13.0 or later
- One or more [ESP32 SmallHD Tally Bridge](https://github.com/Kunkles/esp32-smallhd-tally-light) units on the same network

---

## Usage

### Adding a Unit

Click **+** in the toolbar. Enter a name (e.g. `Camera 1`) and the unit's IP address or `.local` hostname (e.g. `tally-cam1.local`). Hit **Add**.

> For production use, assign static IPs to each unit and use those instead of `.local` hostnames — mDNS can be unreliable on managed networks.

### Individual Control

Each row shows:
- **Status dot** — red = tally on, grey = off, orange = unreachable
- **ON / OFF buttons** — the active state is highlighted red
- **Name and IP fields** — click either to edit inline, changes save automatically

### Gang Mode

Toggle **Gang Mode** to send to all units simultaneously. **RECORD ON** and **RECORD OFF** buttons appear and individual controls are greyed out while gang is active.

### Edit Mode

Click **Edit** in the toolbar to enter edit mode:
- Checkboxes appear on each row — select multiple units
- **Delete Selected** appears in the toolbar once anything is checked
- Name and IP fields remain editable
- Right-click any row to delete a single unit without entering edit mode

---

## Status Polling

The app polls each unit's `/status` endpoint every 5 seconds to keep the dots in sync with the actual hardware state.

---

## Building from Source

Requires Xcode 15+ and macOS 13+.

1. Clone the repo
2. Open `TallyController.xcodeproj`
3. Set your Team under **Signing & Capabilities**
4. Build and run

---

## Related

- **Firmware:** [esp32-smallhd-tally-light](https://github.com/Kunkles/esp32-smallhd-tally-light) — ESP32-S3 HTTP tally bridge for SmallHD monitors

---

*32Thirteen Productions LLC*
