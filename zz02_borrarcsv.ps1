# =================================================================
# SCRIPT DE ELIMINACIÓN DE USUARIOS Y DIRECTORIOS DESDE CSV
# =================================================================

# Importamos el archivo CSV
$usuarios = Import-Csv "usuarios.csv" -Delimiter ","

# Configuración de ruta base (Debe ser la misma que la del script de creación)
$basePathW = "W:" 

# Mapeo de rutas relativas para localizar las carpetas
$rutasRelativas = @{
    "User-Jefes"         = "datos\jefes"
    "User-IT"           = "datos\informaticos"
    "User-Ventas"       = "datos\empleados\ventas"
    "User-Contabilidad" = "datos\empleados\contabilidad"
    "User-RRHH"         = "datos\empleados\rrhh"
}

foreach ($fila in $usuarios) {
    $userCSV  = $fila.Usuario
    $baseUser = $fila.UsuarioBase

    Write-Host "--- Eliminando: $userCSV ---" -ForegroundColor Yellow

    # 1. Eliminar el usuario de Active Directory
    if (Get-ADUser -Identity $userCSV -ErrorAction SilentlyContinue) {
        try {
            Remove-ADUser -Identity $userCSV -Confirm:$false -ErrorAction Stop
            Write-Host "[+] Usuario $userCSV eliminado de AD." -ForegroundColor Green
        }
        catch {
            Write-Warning "[-] No se pudo eliminar el usuario $userCSV de AD: $($_.Exception.Message)"
        }
    } else {
        Write-Host "[!] El usuario $userCSV no existe en AD." -ForegroundColor Gray
    }

    # 2. Eliminar la carpeta personal (Home Directory)
    $relPath = $rutasRelativas[$baseUser]
    $folderPath = "$basePathW\$relPath\$userCSV"

    if (Test-Path $folderPath) {
        try {
            # Borra la carpeta y todo su contenido (-Recurse) de forma forzada (-Force)
            Remove-Item -Path $folderPath -Recurse -Force -ErrorAction Stop
            Write-Host "[+] Carpeta $folderPath eliminada." -ForegroundColor Green
        }
        catch {
            Write-Warning "[-] Error al borrar la carpeta $folderPath : $($_.Exception.Message)"
        }
    } else {
        Write-Host "[!] No se encontró la carpeta en $folderPath" -ForegroundColor Gray
    }
}

Write-Host "`nProceso de limpieza finalizado." -ForegroundColor White -BackgroundColor DarkGreen