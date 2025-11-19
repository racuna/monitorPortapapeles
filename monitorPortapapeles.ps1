# Monitor de Portapapeles - Notificaciones en Windows
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$icon = [System.Drawing.SystemIcons]::Information

# Hash del contenido anterior
$hashAnterior = ""

function Mostrar-Notificacion {
    param(
        [string]$titulo,
        [string]$mensaje
    )
    
    $notificacion = New-Object System.Windows.Forms.NotifyIcon
    $notificacion.Icon = $icon
    $notificacion.BalloonTipTitle = $titulo
    $notificacion.BalloonTipText = $mensaje
    $notificacion.Visible = $true
    $notificacion.ShowBalloonTip(3000)
    
    Start-Sleep -Seconds 3
    $notificacion.Dispose()
}

function Obtener-Hash {
    param([string]$texto)
    if (-not $texto) { return "" }
    $sha = [System.Security.Cryptography.SHA256]::Create()
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($texto)
    $hashBytes = $sha.ComputeHash($bytes)
    return ([BitConverter]::ToString($hashBytes)) -replace "-", ""
}

Mostrar-Notificacion -titulo "Monitor de Portapapeles" -mensaje "Iniciado correctamente. Monitoreando cambios..."

while ($true) {
    try {
        $contenidoActual = Get-Clipboard -Format Text -ErrorAction SilentlyContinue

        # Generar hash
        $hashActual = Obtener-Hash $contenidoActual

        # Detectar cambio REAL
        if ($hashActual -and $hashActual -ne $hashAnterior) {

            # Crear preview
            $preview = $contenidoActual
            if ($preview.Length -gt 50) {
                $preview = $preview.Substring(0, 50) + "..."
            }

            Mostrar-Notificacion -titulo "Portapapeles Actualizado" -mensaje "Copiado: $preview"

            # Guardar nuevo hash
            $hashAnterior = $hashActual

            # BLOQUEAR nuevos cambios por 300 ms (Word envía múltiples actualizaciones)
            Start-Sleep -Milliseconds 300
        }

        Start-Sleep -Milliseconds 200

    } catch {
        Start-Sleep -Seconds 1
    }
}
