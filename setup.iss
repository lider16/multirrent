[Setup]
AppName=Flutter Application 1
AppVersion=1.0
DefaultDirName={pf}\Flutter Application 1
DefaultGroupName=Flutter Application 1
OutputDir=.
OutputBaseFilename=flutter_application_1_setup
Compression=lzma
SolidCompression=yes
PrivilegesRequired=admin

[Languages]
Name: "spanish"; MessagesFile: "compiler:Languages\Spanish.isl"

[Tasks]
Name: "desktopicon"; Description: "Crear icono en el escritorio"; GroupDescription: "Iconos adicionales:"

[Files]
Source: "build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\Flutter Application 1"; Filename: "{app}\flutter_application_1.exe"; WorkingDir: "{app}"
Name: "{commondesktop}\Flutter Application 1"; Filename: "{app}\flutter_application_1.exe"; WorkingDir: "{app}"; Tasks: desktopicon

[Run]
Filename: "{app}\flutter_application_1.exe"; Description: "Ejecutar Flutter Application 1"; Flags: nowait postinstall skipifsilent