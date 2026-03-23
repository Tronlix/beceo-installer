# BeCEO Installer

One-click installer for BeCEO on Windows and macOS.

## Installation

### Windows
Download `BeCEO-Setup-*.exe` from [Releases](https://github.com/Tronlix/beceo-installer/releases) and double-click to install.

### macOS
Open Terminal and run:
```bash
curl -fsSL https://raw.githubusercontent.com/Tronlix/beceo-installer/main/mac/install.sh -o /tmp/beceo-install.sh && bash /tmp/beceo-install.sh
```

---

## Files

| File | Description |
|------|-------------|
| `BeCEO-Setup.iss` | Inno Setup script — compile this to produce the `.exe` installer |
| `install.ps1` | PowerShell script that handles Node.js detection, installation, and `beceo setup` |
| `start-beceo.bat` | Launcher — double-click to start BeCEO (placed on Desktop after install) |
| `uninstall-data.ps1` | Cleanup script run during uninstall — removes service, Task Scheduler entry, and optionally user data |
| `beceo-V1Beta.tgz` | BeCEO package |
| `beceo.ico` | BeCEO application icon |

## Build Requirements

- [Inno Setup](https://jrsoftware.org/isdl.php) (free)
- The `beceo-*.tgz` package file (produced by `npm pack` in the repo root)

## How to Build

1. Make sure `beceo-V1Beta.tgz` is in this folder
2. Open `BeCEO-Setup.iss` with Inno Setup Compiler
3. Press **Build → Compile** (`Ctrl+F9`)
4. The installer is output to `output/BeCEO-Setup-1.0.0-Beta.exe`

> You can also use GitHub Actions to build automatically — see `.github/workflows/build-installer.yml`

## User Installation Flow

1. Download and double-click `BeCEO-Setup-*.exe`
2. Installer detects Node.js — downloads and installs v22 if missing
3. Installs BeCEO via `npm install -g`
4. Opens `beceo setup` wizard in a new window for initial configuration
5. Creates a **BeCEO** shortcut on the Desktop and Start Menu

## Launching BeCEO

After installation, users can start BeCEO by:
- Double-clicking the **BeCEO** shortcut on the Desktop
- Running `beceo start` in any terminal

BeCEO runs as a background Windows Scheduled Task (`OpenClaw Gateway`).

## Uninstall

Use **Add or Remove Programs → BeCEO → Uninstall**.

The uninstaller will:
1. Stop the running BeCEO service
2. Remove the Windows Scheduled Task
3. Uninstall the npm package
4. Ask whether to delete user data (`~/.beceo`, `~/.openclaw`)

## Security Warning

Windows may show an "Unknown Publisher" warning when running the installer.
This is because the `.exe` is not code-signed.

To proceed: click **More info → Run anyway**.

For production deployments, consider purchasing a code signing certificate
(e.g. [Microsoft Trusted Signing](https://learn.microsoft.com/en-us/azure/trusted-signing/) at ~$10/month).

## Troubleshooting

**BeCEO fails to start after reinstall**

The Windows Scheduled Task may be stuck. Run in PowerShell (Admin):
```powershell
schtasks /Delete /F /TN "OpenClaw Gateway"
beceo start
```

**Node.js version error**

BeCEO requires Node.js v22.12.0+. Check your version:
```
node --version
```

**Setup wizard didn't appear**

Run manually:
```
beceo setup
```

## Uninstall (macOS)

To stop BeCEO and remove it from startup:
```bash
# Stop the service and remove Launch Agents
beceo stop
launchctl unload ~/Library/LaunchAgents/ai.openclaw.gateway.plist 2>/dev/null
launchctl unload ~/Library/LaunchAgents/com.openclaw.beceo.plist 2>/dev/null
rm -f ~/Library/LaunchAgents/ai.openclaw.gateway.plist
rm -f ~/Library/LaunchAgents/com.openclaw.beceo.plist

# Uninstall the npm package
npm uninstall -g beceo

# Optionally remove user data
rm -rf ~/.openclaw ~/.beceo
```
