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
MinVersion=10.0
ExtraDiskSpaceRequired=200000000

[Languages]
Name: "spanish"; MessagesFile: "compiler:Languages\Spanish.isl"

[Tasks]
Name: "desktopicon"; Description: "Crear icono en el escritorio"; GroupDescription: "Iconos adicionales:"

[Files]
Source: "build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "https://aka.ms/vs/17/release/vc_redist.x64.exe"; DestDir: "{tmp}"; DestName: "vc_redist.x64.exe"; Flags: external
Source: "https://download.visualstudio.microsoft.com/download/pr/014120d7-d689-4305-befd-3cb711108212/0307177e14752e3595fac542587d2d424/dotnetfx48.exe"; DestDir: "{tmp}"; DestName: "dotnetfx48.exe"; Flags: external

[Icons]
Name: "{group}\Flutter Application 1"; Filename: "{app}\flutter_application_1.exe"; WorkingDir: "{app}"
Name: "{commondesktop}\Flutter Application 1"; Filename: "{app}\flutter_application_1.exe"; WorkingDir: "{app}"; Tasks: desktopicon

[Run]
Filename: "{tmp}\vc_redist.x64.exe"; Parameters: "/quiet /norestart"; StatusMsg: "Instalando Visual C++ Redistributables..."; Flags: skipifdoesntexist
Filename: "{tmp}\dotnetfx48.exe"; Parameters: "/quiet /norestart"; StatusMsg: "Instalando .NET Framework 4.8..."; Flags: skipifdoesntexist
Filename: "{app}\flutter_application_1.exe"; Description: "Ejecutar Flutter Application 1"; Flags: nowait postinstall skipifsilent