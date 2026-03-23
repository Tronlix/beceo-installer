; BeCEO Installer - Inno Setup Script
; Open with Inno Setup Compiler -> Build -> Compile

#define AppName "BeCEO"
#define AppVersion "1.0.0-Beta"
#define AppPublisher "BeCEO.ai"
#define AppURL "https://github.com/your-org/beceo"

[Setup]
AppId={{B3C30E2A-1234-4567-89AB-CDEF01234567}
AppName={#AppName}
AppVersion={#AppVersion}
AppPublisher={#AppPublisher}
AppPublisherURL={#AppURL}
DefaultDirName={autopf}\{#AppName}
DefaultGroupName={#AppName}
OutputDir=.\output
OutputBaseFilename=BeCEO-Setup-{#AppVersion}
SetupIconFile=beceo.ico
Compression=lzma
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=admin

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Files]
; BeCEO package
Source: "beceo-V1Beta.tgz"; DestDir: "{tmp}"; Flags: deleteafterinstall
; Installer script
Source: "install.ps1"; DestDir: "{tmp}"; Flags: deleteafterinstall
; GUI Setup wizard
Source: "setup-gui.ps1"; DestDir: "{tmp}"; Flags: deleteafterinstall
; Silent launcher (stays in app folder)
Source: "start-beceo.bat"; DestDir: "{app}"
; GUI Setup wizard (stays in app folder for launcher to use)
Source: "setup-gui.ps1"; DestDir: "{app}"
; Icon
Source: "beceo.ico"; DestDir: "{app}"
; Uninstall data removal script (stays in app folder)
Source: "uninstall-data.ps1"; DestDir: "{app}"

[Run]
; Step 1: Run PowerShell installer silently in background
Filename: "powershell.exe"; \
    Parameters: "-ExecutionPolicy Bypass -WindowStyle Hidden -File ""{tmp}\install.ps1"""; \
    WorkingDir: "{tmp}"; \
    StatusMsg: "Installing BeCEO..."; \
    Flags: waituntilterminated runhidden

; Step 2: Launch GUI setup wizard (visible, separate process)
Filename: "powershell.exe"; \
    Parameters: "-ExecutionPolicy Bypass -File ""{app}\setup-gui.ps1"""; \
    WorkingDir: "{app}"; \
    StatusMsg: "Running setup wizard..."; \
    Flags: waituntilterminated

[Icons]
; Desktop shortcut - launches via bat
Name: "{autodesktop}\BeCEO"; Filename: "{app}\start-beceo.bat"; IconFilename: "{app}\beceo.ico"
; Start menu
Name: "{group}\BeCEO"; Filename: "{app}\start-beceo.bat"; IconFilename: "{app}\beceo.ico"
Name: "{group}\BeCEO Setup"; Filename: "{cmd}"; Parameters: "/k beceo setup"
Name: "{group}\Uninstall BeCEO"; Filename: "{uninstallexe}"

[UninstallRun]
; Step 1: Stop any running BeCEO process
Filename: "cmd.exe"; Parameters: "/c taskkill /f /im node.exe"; Flags: runhidden; RunOnceId: "KillNode"
; Step 2: Uninstall npm package
Filename: "cmd.exe"; Parameters: "/c npm uninstall -g beceo"; Flags: runhidden; RunOnceId: "NpmUninstall"
; Step 3: Ask user whether to remove .openclaw data
Filename: "powershell.exe"; Parameters: "-ExecutionPolicy Bypass -File ""{app}\uninstall-data.ps1"""; RunOnceId: "RemoveData"

[Messages]
WelcomeLabel1=Welcome to BeCEO Setup
WelcomeLabel2=This wizard will guide you through the installation of BeCEO AI Assistant.%n%nNode.js v22 will be automatically installed if needed. Please make sure your computer is connected to the internet.%n%nClick Next to continue.
FinishedLabel=BeCEO has been successfully installed!%n%nYou can now launch BeCEO from the desktop shortcut or Start Menu.%n%nBeCEO will run silently in the background when started.
