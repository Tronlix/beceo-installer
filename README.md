# BeCEO Windows Installer

One-click Windows installer for BeCEO — automatically installs Node.js, BeCEO, and runs the setup wizard.

## Contents

| File | Description |
|------|-------------|
| `BeCEO-Setup.iss` | Inno Setup script — compile this to produce the `.exe` installer |
| `install.ps1` | PowerShell script that handles Node.js detection, installation, and `beceo setup` |
| `start-beceo.bat` | Launcher — double-click to start BeCEO (placed on Desktop after install) |
| `uninstall-data.ps1` | Cleanup script run during uninstall — removes service, Task Scheduler entry, and optionally user data |

## Requirements (Build Machine)

- [Inno Setup](https://jrsoftware.org/isdl.php) (free)
- The `beceo-*.tgz` package file (produced by `npm pack` in the repo root)

## How to Build

1. Run `npm pack` in the repo root to produce `beceo-X.X.X.tgz`
2. Place it in this folder and rename it to `beceo-V1Beta.tgz` (or update the filename in `install.ps1` and `BeCEO-Setup.iss`)
3. Open `BeCEO-Setup.iss` with Inno Setup Compiler
4. Press **Build → Compile** (`Ctrl+F9`)
5. The installer is output to `installer/output/BeCEO-Setup-1.0.0-Beta.exe`

## User Installation Flow

1. User downloads and double-clicks `BeCEO-Setup-*.exe`
2. Installer detects Node.js — downloads and installs v22 if missing
3. Installs BeCEO via `npm install -g`
4. Opens `beceo setup` wizard in a new window for initial configuration
5. Creates a **BeCEO** shortcut on the Desktop and Start Menu

## User Launch

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
