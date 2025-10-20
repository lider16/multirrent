# Instalador de Multirrent para Windows

Este directorio contiene el script para crear el instalador de la aplicación Multirrent.

## Requisitos previos:
1. Flutter con soporte para Windows (Visual Studio instalado)
2. Inno Setup instalado (descárgalo de https://jrsoftware.org/isinfo.php)

## Pasos para crear el instalador:

1. **Generar el build de Windows:**
   ```
   flutter build windows
   ```

2. **Ejecutar el script de Inno Setup:**
   - Abre Inno Setup Compiler
   - Carga el archivo `setup.iss`
   - Compila el instalador

3. **Resultado:**
   El instalador `MultirrentInstaller.exe` se creará en esta misma carpeta.

## Uso del instalador:
- Ejecuta `MultirrentInstaller.exe` en cualquier PC con Windows
- Instalará la aplicación en `C:\Program Files\Multirrent`
- Creará un acceso directo en el escritorio (opcional)
- Agregará la app al menú Inicio

¡El instalador estará listo para distribución!