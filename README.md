# BeCEO Windows 安裝程式

一鍵 Windows 安裝程式，自動安裝 Node.js、BeCEO，並執行初始設定精靈。

## 檔案說明

| 檔案 | 說明 |
|------|------|
| `BeCEO-Setup.iss` | Inno Setup 腳本，編譯後產生 `.exe` 安裝程式 |
| `install.ps1` | PowerShell 安裝腳本，負責偵測/安裝 Node.js 並執行 `beceo setup` |
| `start-beceo.bat` | 啟動器，安裝完成後放在桌面，雙擊啟動 BeCEO |
| `uninstall-data.ps1` | 解除安裝時執行的清理腳本，移除服務、工作排程器任務及使用者資料 |
| `beceo-V1Beta.tgz` | BeCEO 套件包 |

## 建置需求（本機編譯）

- [Inno Setup](https://jrsoftware.org/isdl.php)（免費）
- `beceo-*.tgz` 套件檔（在 repo 根目錄執行 `npm pack` 產生）

## 如何建置安裝程式

1. 確認 `beceo-V1Beta.tgz` 在同一個資料夾
2. 用 Inno Setup Compiler 開啟 `BeCEO-Setup.iss`
3. 按 **Build → Compile**（或 `Ctrl+F9`）
4. 安裝程式輸出至 `output/BeCEO-Setup-1.0.0-Beta.exe`

> 也可透過 GitHub Actions 自動編譯，詳見 `.github/workflows/build-installer.yml`

## 使用者安裝流程

1. 下載並雙擊 `BeCEO-Setup-*.exe`
2. 安裝程式自動偵測 Node.js — 若未安裝或版本過舊，自動下載安裝 v22
3. 透過 `npm install -g` 安裝 BeCEO
4. 在新視窗開啟 `beceo setup` 精靈，引導完成初始設定
5. 桌面及開始選單自動建立 **BeCEO** 捷徑

## 啟動 BeCEO

安裝完成後，使用者可透過以下方式啟動：
- 雙擊桌面上的 **BeCEO** 捷徑
- 在任意終端輸入 `beceo start`

BeCEO 以 Windows 工作排程器背景任務（`OpenClaw Gateway`）形式運行。

## 解除安裝

至「新增或移除程式」→ BeCEO → 解除安裝。

解除安裝程式會依序：
1. 停止 BeCEO 服務
2. 移除 Windows 工作排程器任務
3. 解除安裝 npm 套件
4. 詢問是否一併刪除使用者資料（`~/.beceo`、`~/.openclaw`）

## 常見問題

**重新安裝後 BeCEO 無法啟動**

Windows 工作排程器任務可能有殘留。以系統管理員開啟 PowerShell 執行：
```powershell
schtasks /Delete /F /TN "OpenClaw Gateway"
beceo start
```

**Node.js 版本錯誤**

BeCEO 需要 Node.js v22.12.0 以上，確認版本：
```
node --version
```

**設定精靈沒有出現**

手動執行：
```
beceo setup
```
