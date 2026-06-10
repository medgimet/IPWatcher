# IPWatcher

macOS menu bar app that monitors your public IP address.

## What it does

- Shows current IP in the menu bar
- Sends a notification when IP changes
- Runs silently in the background with no Dock icon

## Install

```bash
git clone https://github.com/medgimet/IPWatcher.git
cd IPWatcher
swift build -c release
.build/release/IPWatcher &
```

On first launch a settings window will appear — enter your target IP and check interval.
