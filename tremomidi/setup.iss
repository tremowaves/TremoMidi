[Setup]
AppName=TremoMidi
AppVersion=1.0.0
AppPublisher=TremoMidi
AppPublisherURL=https://github.com/yourusername/tremomidi
AppSupportURL=https://github.com/yourusername/tremomidi
AppUpdatesURL=https://github.com/yourusername/tremomidi
DefaultDirName={autopf}\TremoMidi
DefaultGroupName=TremoMidi
AllowNoIcons=yes
LicenseFile=LICENSE
OutputDir=installer
OutputBaseFilename=TremoMidi-Setup
SetupIconFile=windows\runner\resources\app_icon.ico
Compression=lzma
SolidCompression=yes
WizardStyle=modern
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64
PrivilegesRequired=lowest

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked
Name: "quicklaunchicon"; Description: "{cm:CreateQuickLaunchIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked; OnlyBelowVersion: 6.1; Check: not IsAdminInstallMode

[Files]
Source: "build\windows\x64\runner\Release\tremomidi.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "assets\TremoSoundFont.sf2"; DestDir: "{app}\assets"; Flags: ignoreversion

[Icons]
Name: "{group}\TremoMidi"; Filename: "{app}\tremomidi.exe"
Name: "{group}\{cm:UninstallProgram,TremoMidi}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\TremoMidi"; Filename: "{app}\tremomidi.exe"; Tasks: desktopicon
Name: "{userappdata}\Microsoft\Internet Explorer\Quick Launch\TremoMidi"; Filename: "{app}\tremomidi.exe"; Tasks: quicklaunchicon

[Run]
Filename: "{app}\tremomidi.exe"; Description: "{cm:LaunchProgram,TremoMidi}"; Flags: nowait postinstall skipifsilent

[Code]
function InitializeSetup(): Boolean;
begin
  Result := True;
end;

[Registry]
Root: HKCU; Subkey: "Software\TremoMidi"; ValueType: string; ValueName: "InstallPath"; ValueData: "{app}"; Flags: uninsdeletekey 