# =================================================================
# SCRIPT DE ELIMINACIÓN ACTUALIZADO: USUARIOS, PERFILES Y CARPETAS
# =================================================================

# 1. Mantenemos la estructura completa para saber QUÉ borrar y DÓNDE
$configuracion = @(
    @{User = "User-Jefes";         RelPath = "jefes";           EsJefe = $true}
    @{User = "User-IT";            RelPath = "informaticos";    EsJefe = $false}
    @{User = "User-Ventas";        RelPath = "empleados\ventas"; EsJefe = $false}
    @{User = "User-Contabilidad";  RelPath = "empleados\contabilidad"; EsJefe = $false}
    @{User = "User-RRHH";          RelPath = "empleados\rrhh";   EsJefe = $false}
)

# Rutas base (Deben coincidir con las del script de creación)
$basePath      = "\\DNSSERVER\datos$" 
$profileServer = "\\DNSSERVER\perfiles$"

Write-Host "Iniciando proceso de limpieza profunda..." -ForegroundColor Yellow
Write-Host "-------------------------------------------------------"

foreach ($item in $configuracion) {
    $nombreUser = $item.User
    
    # A. Comprobar si el usuario existe en AD
    $userExists = Get-ADUser -Filter "SamAccountName -eq '$nombreUser'"

    if ($userExists) {
        try {
            # 1. Eliminar el usuario de Active Directory
            Remove-ADUser -Identity $nombreUser -Confirm:$false -ErrorAction Stop
            Write-Host "[OK] Usuario '$nombreUser' eliminado de AD." -ForegroundColor Green

            # 2. Borrar Carpeta Personal (Home Directory)
            # Reconstruimos la ruta: \\DNSSERVER\datos$\ruta\usuario
            $hPath = Join-Path $basePath "$($item.RelPath)\$nombreUser"
            if (Test-Path $hPath) {
                Remove-Item -Path $hPath -Recurse -Force -ErrorAction SilentlyContinue
                Write-Host "[i] Carpeta personal en '$hPath' eliminada." -ForegroundColor Gray
            }

            # 3. Borrar Perfil Móvil (Solo si es jefe)
            if ($item.EsJefe) {
                $pPath = Join-Path $profileServer $nombreUser
                if (Test-Path $pPath) {
                    # Nota: A veces los perfiles requieren tomar posesión antes de borrar si el Admin no tiene permisos
                    Remove-Item -Path $pPath -Recurse -Force -ErrorAction SilentlyContinue
                    Write-Host "[i] Perfil móvil en '$pPath' eliminado." -ForegroundColor Gray
                }
            }
        }
        catch {
            Write-Error "No se pudo limpiar completamente a $nombreUser : $($_.Exception.Message)"
        }
    }
    else {
        Write-Host "[!] El usuario '$nombreUser' no existe en AD, saltando..." -ForegroundColor Gray
    }
}

Write-Host "-------------------------------------------------------"
Write-Host "Limpieza finalizada con éxito." -ForegroundColor Cyan