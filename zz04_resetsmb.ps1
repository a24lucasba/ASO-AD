# 1. Definición de los Shares (Deben coincidir con los nombres del script original)
$recursosCompartidos = @(
    "ventas",
    "contabilidad",
    "rrhh",
    "jefes",
    "informaticos",
    "Salas_Reuniones"
)

Write-Host "Iniciando la eliminación de SMB Shares..." -ForegroundColor Cyan

foreach ($nombreShare in $recursosCompartidos) {
    # Verificar si el recurso compartido existe
    if (Get-SmbShare -Name $nombreShare -ErrorAction SilentlyContinue) {
        try {
            # Eliminar el recurso compartido (esto NO borra los archivos ni las carpetas)
            Remove-SmbShare -Name $nombreShare -Confirm:$false -ErrorAction Stop
            Write-Host "ELIMINADO: El recurso '$nombreShare' ya no está compartido." -ForegroundColor Green
        } catch {
            Write-Host "ERROR: No se pudo eliminar '$nombreShare' : $($_.Exception.Message)" -ForegroundColor Red
        }
    } else {
        Write-Host "AVISO: El recurso '$nombreShare' no existe o ya fue eliminado." -ForegroundColor Yellow
    }
}

Write-Host "`nProceso finalizado." -ForegroundColor Cyan