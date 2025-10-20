[Setup]
AppName=Multirrent
AppVersion=1.0
DefaultDirName={pf}\Multirrent
DefaultGroupName=Multirrent
OutputDir=.
OutputBaseFilename=MultirrentInstaller
Compression=lzma
SolidCompression=yes

[Languages]
Name: "spanish"; MessagesFile: "compiler:Languages\Spanish.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "..\build\windows\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\Multirrent"; Filename: "{app}\flutter_application_1.exe"
Name: "{commondesktop}\Multirrent"; Filename: "{app}\flutter_application_1.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\flutter_application_1.exe"; Description: "{cm:LaunchProgram,Multirrent}"; Flags: nowait postinstall skipifsilent