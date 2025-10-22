# Instaladores Manuales de Dependencias

Esta carpeta contiene instaladores manuales para dependencias requeridas por la aplicación Flutter Application 1 en Windows.

## Archivos

- `vc_redist.x64.exe`: Visual C++ Redistributable for Visual Studio 2015-2022 (x64)
- `dotnetfx48.exe`: Microsoft .NET Framework 4.8

## Cuándo usar

Instala estos manualmente si la aplicación falla al iniciarse con errores de DLL faltantes o problemas de .NET Framework, incluso después de usar el instalador automático.

## Instrucciones

1. Ejecuta `vc_redist.x64.exe` como administrador y sigue las instrucciones.
2. Ejecuta `dotnetfx48.exe` como administrador y sigue las instrucciones.
3. Reinicia el computador si es necesario.
4. Intenta ejecutar la aplicación nuevamente.

## Notas

- Estos instaladores son oficiales de Microsoft.
- Si ya están instalados, los instaladores lo detectarán y no harán cambios.
- Para soporte, consulta los logs de error de la aplicación.