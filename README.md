# 📋 Monitor de Portapapeles Multiplataforma

Monitor ligero y eficiente que muestra notificaciones cada vez que copias algo al portapapeles. Compatible con Windows y Linux (X11/Wayland).


![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20Linux-lightgrey.svg)

## ✨ Características

- 🔔 **Notificaciones en tiempo real** cuando copias texto
- 👀 **Vista previa** del contenido copiado (primeros 50 caracteres)
- 🔄 **Detección inteligente** de cambios mediante hash SHA256
- 🚫 **Anti-duplicados** - Evita notificaciones múltiples del mismo contenido
- 💻 **Multiplataforma** - Windows y Linux
- 🎨 **Adaptativo** - Detecta automáticamente el entorno de escritorio

## 📦 Instalación

### Windows

**Requisitos:** Windows 10/11 con PowerShell 5.1 o superior

1. Descarga el script `monitorPortapapeles.ps1`
2. ¡Listo! No requiere dependencias adicionales

### Linux

**Requisitos:** Bash y una herramienta de portapapeles

#### Ubuntu/Debian (X11)
```bash
sudo apt install xclip libnotify-bin
```

#### Ubuntu/Debian (Wayland)
```bash
sudo apt install wl-clipboard libnotify-bin
```

#### Fedora/RHEL (X11)
```bash
sudo dnf install xclip libnotify
```

#### Fedora/RHEL (Wayland)
```bash
sudo dnf install wl-clipboard libnotify
```

#### Arch Linux
```bash
sudo pacman -S xclip libnotify  # Para X11
sudo pacman -S wl-clipboard libnotify  # Para Wayland
```

## 🚀 Uso

### Windows
```powershell
# Ejecutar directamente
.\monitorPortapapeles.ps1

# O con PowerShell
powershell -ExecutionPolicy Bypass -File .\monitorPortapapeles.ps1
```

**Nota:** Si aparece un error de política de ejecución, ejecuta:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Linux
```bash
# Dar permisos de ejecución
chmod +x monitor_portapapeles.sh

# Ejecutar
./monitor_portapapeles.sh
```

## 🔄 Ejecutar al Inicio de Sesión

### Windows

#### Método 1: Carpeta de Inicio (Recomendado)

1. Presiona `Win + R` y escribe: `shell:startup`
2. Crea un acceso directo del script en esa carpeta
3. **Propiedades del acceso directo:**
   - **Destino:** 
   ```
   powershell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -File "C:\ruta\completa\monitorPortapapeles.ps1"
   ```
   - **Ejecutar:** Minimizada

#### Método 2: Programador de Tareas

1. Abre el **Programador de tareas** (`taskschd.msc`)
2. Click en **Crear tarea básica**
3. **Nombre:** Monitor de Portapapeles
4. **Desencadenador:** Al iniciar sesión
5. **Acción:** Iniciar un programa
   - **Programa:** `powershell.exe`
   - **Argumentos:** 
   ```
   -WindowStyle Hidden -ExecutionPolicy Bypass -File "C:\ruta\completa\monitorPortapapeles.ps1"
   ```
6. ✅ Finalizar

#### Método 3: Registro de Windows

Crea un archivo `instalar_inicio.reg` con este contenido:

```reg
Windows Registry Editor Version 5.00

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run]
"MonitorPortapapeles"="powershell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -File \"C:\\ruta\\completa\\monitorPortapapeles.ps1\""
```

Ejecuta el archivo `.reg` (ajusta la ruta primero).

---

### Linux

#### Método 1: Systemd (Recomendado para la mayoría)

1. Crea el archivo de servicio de usuario:
```bash
mkdir -p ~/.config/systemd/user
nano ~/.config/systemd/user/clipboard-monitor.service
```

2. Agrega el siguiente contenido:
```ini
[Unit]
Description=Monitor de Portapapeles
After=graphical-session.target

[Service]
Type=simple
ExecStart=/ruta/completa/monitor_portapapeles.sh
Restart=on-failure
RestartSec=5

[Install]
WantedBy=default.target
```

3. Habilita e inicia el servicio:
```bash
systemctl --user enable clipboard-monitor.service
systemctl --user start clipboard-monitor.service

# Verificar estado
systemctl --user status clipboard-monitor.service
```

#### Método 2: GNOME (Aplicaciones de Inicio)

1. Abre **Aplicaciones de Inicio** (`gnome-session-properties`)
2. Click en **Añadir**
3. **Nombre:** Monitor de Portapapeles
4. **Comando:** `/ruta/completa/monitor_portapapeles.sh`
5. **Comentario:** Notificaciones de portapapeles
6. Guarda

#### Método 3: KDE Plasma (Autostart)

1. Abre **Configuración del Sistema** → **Inicio y apagado** → **Autoarranque**
2. Click en **Añadir** → **Añadir script de shell**
3. Selecciona el script `monitor_portapapeles.sh`
4. Aplica cambios

#### Método 4: XFCE (Aplicaciones autoiniciadas)

1. Abre **Configuración** → **Sesión e inicio**
2. Pestaña **Autoarranque de aplicaciones**
3. Click en **Añadir**
4. **Nombre:** Monitor de Portapapeles
5. **Comando:** `/ruta/completa/monitor_portapapeles.sh`
6. Guarda

#### Método 5: Crontab (Universal)

```bash
crontab -e
```

Agrega esta línea:
```cron
@reboot /ruta/completa/monitor_portapapeles.sh
```

#### Método 6: ~/.profile o ~/.bashrc

Agrega al final del archivo `~/.profile`:
```bash
# Monitor de Portapapeles
if [ -z "$CLIPBOARD_MONITOR_STARTED" ]; then
    export CLIPBOARD_MONITOR_STARTED=1
    /ruta/completa/monitor_portapapeles.sh &
fi
```

## 🛑 Detener el Monitor

### Windows
```powershell
# Buscar el proceso
Get-Process | Where-Object {$_.ProcessName -eq "powershell" -and $_.CommandLine -like "*monitorPortapapeles*"}

# Detener
Stop-Process -Name powershell -Force
```

O simplemente cierra la ventana de PowerShell.

### Linux
```bash
# Encontrar el proceso
ps aux | grep monitor_portapapeles.sh

# Detener (reemplaza PID con el número del proceso)
kill PID

# Para systemd
systemctl --user stop clipboard-monitor.service
```

## 🔧 Personalización

### Cambiar duración de notificaciones

**Windows** (`monitorPortapapeles.ps1`):
```powershell
$notificacion.ShowBalloonTip(3000)  # 3000 = 3 segundos
```

**Linux** (`monitor_portapapeles.sh`):
```bash
notify-send -i edit-copy "$titulo" "$mensaje" -t 3000  # 3000 = 3 segundos
```

### Cambiar longitud del preview

Modifica el valor `50` en ambos scripts:
```bash
if [ ${#preview} -gt 50 ]; then  # Cambiar 50 por el valor deseado
```

### Cambiar intervalo de verificación

**Windows:**
```powershell
Start-Sleep -Milliseconds 200  # Verificar cada 200ms
```

**Linux:**
```bash
sleep 0.2  # Verificar cada 0.2 segundos
```

## 🐛 Solución de Problemas

### Windows

**Problema:** "No se puede ejecutar scripts en este sistema"
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**Problema:** Las notificaciones no aparecen
- Verifica que las notificaciones de Windows estén habilitadas
- Revisa la configuración en: Configuración → Sistema → Notificaciones

### Linux

**Problema:** "Command not found: xclip"
```bash
# Instala la herramienta de portapapeles correspondiente
sudo apt install xclip  # X11
sudo apt install wl-clipboard  # Wayland
```

**Problema:** Las notificaciones no aparecen
```bash
# Verifica que notify-send esté instalado
which notify-send

# Instala si es necesario
sudo apt install libnotify-bin
```

**Problema:** No funciona en Wayland
```bash
# Instala wl-clipboard
sudo apt install wl-clipboard
```

## 📊 Compatibilidad

### Windows
- ✅ Windows 10
- ✅ Windows 11
- ✅ Windows Server 2016+

### Linux - Entornos de Escritorio
- ✅ GNOME (X11/Wayland)
- ✅ KDE Plasma (X11/Wayland)
- ✅ XFCE
- ✅ MATE
- ✅ Cinnamon
- ✅ i3/Sway
- ✅ Budgie
- ✅ LXQt/LXDE

### Linux - Distribuciones
- ✅ Ubuntu/Debian
- ✅ Fedora/RHEL
- ✅ Arch Linux
- ✅ openSUSE
- ✅ Manjaro
- ✅ Linux Mint

## 🤝 Contribuir

Las contribuciones son bienvenidas. Por favor:

1. Fork el proyecto
2. Crea una rama para tu función (`git checkout -b feature/NuevaFuncion`)
3. Commit tus cambios (`git commit -m 'Agrega nueva función'`)
4. Push a la rama (`git push origin feature/NuevaFuncion`)
5. Abre un Pull Request

## 📝 Licencia

Este proyecto está bajo la Licencia GNU2.0



- Inspirado en la necesidad de tener un monitor de portapapeles ligero y multiplataforma


Tips: https://plisio.net/donate/GevVszjz

---

**⭐ Si este proyecto te fue útil, considera darle una estrella en GitHub!**
