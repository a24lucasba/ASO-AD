# =================================================================
# SCRIPT DE CREACIÓN DE USUARIOS DESDE CSV - ACTIVE DIRECTORY
# =================================================================

# 1. Configuración de mapeo según el Grupo del CSV
$mapeoConfig = @{
    "G-JEFES"        = @{OU = "JEFES"; RelPath = "Personales\jefes" }
    "G-INFORMATICOS" = @{OU = "INFORMATICOS"; RelPath = "Personales\informaticos" }
    "G-VENTAS"       = @{OU = "VENTAS"; RelPath = "Personales\empleados\ventas" }
    "G-CONTABILIDAD" = @{OU = "CONTABILIDAD"; RelPath = "Personales\empleados\contabilidad" }
    "G-RRHH"         = @{OU = "RRHH"; RelPath = "Personales\empleados\rrhh" }
}

$grupoGeneral = "G-USUARIOS"
$grupoEmpleados = "G-EMPLEADO"
$loginScript = "abrir_aviso.bat"
$password = ConvertTo-SecureString "abc123.." -AsPlainText -Force

# 2. Importar el archivo CSV
$usuariosCSV = Import-Csv -Path ".\usuarios.csv" -Delimiter ","

foreach ($usuario in $usuariosCSV) {
    $samAccountName = $usuario.Usuario
    $nombreCompleto = "$($usuario.Nombre) $($usuario.Apellidos)"
    $grupoCSV = $usuario.Grupo
    
    # Obtener configuración específica según el grupo
    $config = $mapeoConfig[$grupoCSV]

    if ($config) {
        $ouName = $config.OU
        $homeDir = "W:\$($config.RelPath)\$samAccountName"
        $targetOU = Get-ADOrganizationalUnit -Filter "Name -eq '$ouName'"

        if ($targetOU) {
            try {
                Write-Host "--- Procesando: $nombreCompleto ($samAccountName) ---" -ForegroundColor Cyan
                
                # Crear el usuario
                New-ADUser -Name $samAccountName `
                    -SamAccountName $samAccountName `
                    -DisplayName $nombreCompleto `
                    -GivenName $usuario.Nombre `
                    -Surname $usuario.Apellidos `
                    -Enabled $true `
                    -AccountPassword $password `
                    -ChangePasswordAtLogon $true `
                    -Path $targetOU.DistinguishedName `
                    -ScriptPath $loginScript `
                    -HomeDirectory $homeDir `
                    -HomeDrive "H:" `
                    -ErrorAction Stop

                # 1. Asignar grupo específico del CSV
                Add-ADGroupMember -Identity $grupoCSV -Members $samAccountName
                Write-Host "[+] Grupo: $grupoCSV" -ForegroundColor Gray

                # 2. Asignar a G-EMPLEADOS si es de Ventas, Contabilidad o RRHH
                if ($ouName -in @("VENTAS", "CONTABILIDAD", "RRHH")) {
                    Add-ADGroupMember -Identity $grupoEmpleados -Members $samAccountName
                    Write-Host "[+] Grupo: $grupoEmpleados" -ForegroundColor Yellow
                }

                # 3. Asignar a grupo general
                Add-ADGroupMember -Identity $grupoGeneral -Members $samAccountName
                Write-Host "[+] Grupo: $grupoGeneral" -ForegroundColor Gray
                
                Write-Host "¡Éxito: $samAccountName creado correctamente!" -ForegroundColor Green
            }
            catch {
                Write-Warning "Error al crear a $samAccountName : $($_.Exception.Message)"
            }
        }
        else {
            Write-Error "No se encontró la OU: $ouName para el usuario $samAccountName"
        }
    }
    else {
        Write-Warning "El grupo '$grupoCSV' del usuario $samAccountName no tiene mapeo definido."
    }
}