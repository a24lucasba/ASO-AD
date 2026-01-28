# =================================================================
# SCRIPT DE ELIMINACIÓN DE USUARIOS BASE
# =================================================================

# 1. Definimos la misma lista que en el script de creación
$configuracion = @(
    @{User = "User-Jefes" },
    @{User = "User-IT" },
    @{User = "User-Ventas" },
    @{User = "User-Contabilidad" },
    @{User = "User-RRHH" }
)

Write-Host "Iniciando proceso de limpieza de usuarios..." -ForegroundColor Yellow
Write-Host "------------------------------------------------"

foreach ($item in $configuracion) {
    $nombreUser = $item.User

    # A. Comprobar si el usuario existe antes de intentar borrar
    $userExists = Get-ADUser -Filter "SamAccountName -eq '$nombreUser'"

    if ($userExists) {
        try {
            # B. Eliminar el usuario
            # -Confirm:$false evita que PowerShell pregunte uno por uno
            Remove-ADUser -Identity $nombreUser -Confirm:$false -ErrorAction Stop
            
            Write-Host "[OK] Usuario '$nombreUser' eliminado correctamente." -ForegroundColor Green
        }
        catch {
            Write-Error "No se pudo eliminar a $nombreUser":" $($_.Exception.Message)"
        }
    }
    else {
        Write-Host "[!] El usuario '$nombreUser' no existe, saltando..." -ForegroundColor Gray
    }
}

Write-Host "------------------------------------------------"
Write-Host "Limpieza finalizada." -ForegroundColor Cyan