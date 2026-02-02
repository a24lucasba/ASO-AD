# =================================================================
# SCRIPT OPTIMIZADO: RUTA UNC Y ASIGNACIÓN DE PROPIETARIO
# =================================================================

$configuracion = @(
    @{Grupo = "G-JEFES";         OU = "JEFES";         User = "User-Jefes";          RelPath = "jefes";          EsJefe = $true}
    @{Grupo = "G-INFORMATICOS";  OU = "INFORMATICOS";  User = "User-IT";             RelPath = "informaticos";   EsJefe = $false}
    @{Grupo = "G-VENTAS";        OU = "VENTAS";        User = "User-Ventas";         RelPath = "empleados\ventas"; EsJefe = $false}
    @{Grupo = "G-CONTABILIDAD";  OU = "CONTABILIDAD";  User = "User-Contabilidad";   RelPath = "empleados\contabilidad"; EsJefe = $false}
    @{Grupo = "G-RRHH";          OU = "RRHH";          User = "User-RRHH";           RelPath = "empleados\rrhh"; EsJefe = $false}
)

$loginScript     = "abrir_aviso.bat"
$password        = ConvertTo-SecureString "abc123.." -AsPlainText -Force
# Cambiamos W:\ por la ruta UNC directa
$basePath        = "\\DNSSERVER\datos$" 
$profileServer   = "\\DNSSERVER\perfiles$"

foreach ($item in $configuracion) {
    $u = $item.User
    $ouName = $item.OU
    # La ruta final será: \\DNSSERVER\datos$\ruta\usuario
    $homePath = Join-Path $basePath "$($item.RelPath)\$u"
    
    $profilePath = $null
    if ($item.EsJefe) { $profilePath = "$profileServer\$u" }

    $targetOU = Get-ADOrganizationalUnit -Filter "Name -eq '$ouName'"

    if ($targetOU) {
        try {
            Write-Host "--- Procesando: $u ---" -ForegroundColor Cyan
            
            # 1. Crear el usuario en AD
            $userParams = @{
                Name                  = $u
                SamAccountName        = $u
                DisplayName           = "Usuario Base $ouName"
                Path                  = $targetOU.DistinguishedName
                Enabled               = $true
                AccountPassword       = $password
                ChangePasswordAtLogon = $true
                HomeDrive             = "H:"
                HomeDirectory         = $homePath
                ScriptPath            = $loginScript
                ErrorAction           = "Stop"
            }

            if ($profilePath) { $userParams.Add("ProfilePath", $profilePath) }

            New-ADUser @userParams

            # 2. Agregar al grupo
            Add-ADGroupMember -Identity $item.Grupo -Members $u

            # 3. Crear directorio Home si no existe
            if (-not (Test-Path $homePath)) {
                New-Item -Path $homePath -ItemType Directory -Force | Out-Null
            }

            # 4. Gestión de Permisos y Propiedad (Ownership)
            # ---------------------------------------------------------
            # Deshabilitar herencia y copiar permisos actuales
            icacls $homePath /inheritance:d
            
            # Quitar permisos de "Usuarios" genéricos si existieran
            icacls $homePath /remove "Users"
            
            # Dar control total al usuario
            icacls $homePath /grant "${u}:(OI)(CI)W"
            
            # CAMBIAR EL PROPIETARIO: El usuario debe ser el dueño
            # /setowner cambia el propietario a nivel de sistema de archivos
            icacls $homePath /setowner $u /T /C /L /Q

            Write-Host "[+] Carpeta creada y propiedad asignada a $u" -ForegroundColor Green
            Write-Host "¡Éxito: $u creado y vinculado!" -ForegroundColor Green
        }
        catch {
            Write-Warning "Error con $u : $($_.Exception.Message)"
        }
    }
    else {
        Write-Error "No se encontró la OU: $ouName"
    }
}