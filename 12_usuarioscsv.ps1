# =================================================================
# SCRIPT COMPLETO: IMPORTACIÓN CSV, CREACIÓN DE USUARIO, 
# CARPETA PERSONAL Y ASIGNACIÓN DE PROPIETARIO
# =================================================================

# 1. Configuración de Mapeos
$mapaConfig = @{
    "User-Jefes"         = @{OU = "JEFES";         RelPath = "datos\jefes";           EsJefe = $true}
    "User-IT"            = @{OU = "INFORMATICOS";  RelPath = "datos\informaticos";    EsJefe = $false}
    "User-Ventas"        = @{OU = "VENTAS";        RelPath = "datos\empleados\ventas"; EsJefe = $false}
    "User-Contabilidad"  = @{OU = "CONTABILIDAD";  RelPath = "datos\empleados\contabilidad"; EsJefe = $false}
    "User-RRHH"          = @{OU = "RRHH";          RelPath = "datos\empleados\rrhh";   EsJefe = $false}
}

# 2. Variables de Entorno
$csvPath       = "Z:\usuarios.csv"
$loginScript   = "abrir_aviso.bat"
$password      = ConvertTo-SecureString "abc123.." -AsPlainText -Force
$basePath      = "W:\"               # Unidad donde se crearán las carpetas
$profileServer = "\\dnsserver\perfiles$" # Ruta para perfiles móviles

Write-Host "--- Iniciando Importación Masiva ---" -ForegroundColor White

# 3. Procesamiento del CSV
if (Test-Path $csvPath) {
    $usuariosCSV = Import-Csv -Path $csvPath -Delimiter ","

    foreach ($linea in $usuariosCSV) {
        $n    = $linea.Nombre
        $a    = $linea.Apellidos
        $u    = $linea.Usuario
        $g    = $linea.Grupo
        $base = $linea.UsuarioBase

        $infoConfig = $mapaConfig[$base]

        if ($infoConfig) {
            $ouName = $infoConfig.OU
            # Definimos la ruta de la carpeta personal
            $homeDirectoryPath = Join-Path $basePath "$($infoConfig.RelPath)\$u"
            $targetOU = Get-ADOrganizationalUnit -Filter "Name -eq '$ouName'"

            if ($targetOU) {
                try {
                    Write-Host "`nPROCESANDO: $u ($n $a)" -ForegroundColor Cyan
                    
                    # --- A. Parámetros del Usuario ---
                    $userParams = @{
                        Name                  = "$n $a"
                        SamAccountName        = $u
                        GivenName             = $n
                        Surname               = $a
                        Path                  = $targetOU.DistinguishedName
                        Enabled               = $true
                        AccountPassword       = $password
                        ChangePasswordAtLogon = $true
                        HomeDrive             = "H:"
                        HomeDirectory         = $homeDirectoryPath
                        ScriptPath            = $loginScript
                        ErrorAction           = "Stop"
                    }

                    # Añadir Perfil Móvil si es Jefe
                    if ($infoConfig.EsJefe) {
                        $pPath = "$profileServer\$u"
                        $userParams.Add("ProfilePath", $pPath)
                        Write-Host "  [i] Perfil móvil activado." -ForegroundColor Gray
                    }

                    # --- B. Crear Usuario en Active Directory ---
                    New-ADUser @userParams
                    Write-Host "  [OK] Usuario creado en AD." -ForegroundColor Green

                    # --- C. Agregar al Grupo ---
                    Add-ADGroupMember -Identity $g -Members $u
                    Write-Host "  [OK] Agregado al grupo: $g" -ForegroundColor Green

                    # --- D. Creación de Carpeta Física y Permisos ---
                    if (-not (Test-Path $homeDirectoryPath)) {
                        # Crear la carpeta físicamente
                        New-Item -Path $homeDirectoryPath -ItemType Directory -Force | Out-Null
                        Write-Host "  [OK] Carpeta física creada en $homeDirectoryPath" -ForegroundColor Green
                    }

                    # Configuración de Seguridad NTFS con ICACLS
                    # 1. Deshabilitar herencia (D)
                    icacls $homeDirectoryPath /inheritance:d /Q
                    # 2. Eliminar permisos de usuarios genéricos
                    icacls $homeDirectoryPath /remove "Users" /Q
                    # 3. Dar Control Total (F) al usuario de forma recursiva (OI)(CI)
                    icacls $homeDirectoryPath /grant "${u}:(OI)(CI)F" /Q
                    # 4. Asignar al usuario como Propietario (Owner)
                    icacls $homeDirectoryPath /setowner $u /T /C /L /Q
                    
                    Write-Host "  [OK] Permisos y Propiedad (Owner) asignados a $u." -ForegroundColor Green
                    
                }
                catch {
                    Write-Error "  [ERROR] No se pudo procesar a $u : $($_.Exception.Message)"
                }
            }
            else {
                Write-Warning "  [!] No se encontró la OU: $ouName"
            }
        }
        else {
            Write-Warning "  [!] Sin mapeo para UsuarioBase: $base"
        }
    }
}
else {
    Write-Error "No se encontró el archivo CSV en $csvPath"
}

Write-Host "`n--- Proceso Finalizado ---" -ForegroundColor White