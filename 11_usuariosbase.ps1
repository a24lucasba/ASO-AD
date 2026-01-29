# =================================================================
# SCRIPT DE CREACIÓN DE USUARIOS - VERSIÓN FINAL CORREGIDA (W:)
# =================================================================

$configuracion = @(
    @{Grupo = "G-JEFES";        OU = "JEFES";        User = "User-Jefes";        RelPath = "Personales\jefes"}
    @{Grupo = "G-INFORMATICOS"; OU = "INFORMATICOS"; User = "User-IT";           RelPath = "Personales\informaticos"}
    @{Grupo = "G-VENTAS";       OU = "VENTAS";       User = "User-Ventas";       RelPath = "Personales\empleados\ventas"}
    @{Grupo = "G-CONTABILIDAD"; OU = "CONTABILIDAD"; User = "User-Contabilidad"; RelPath = "Personales\empleados\contabilidad"}
    @{Grupo = "G-RRHH";         OU = "RRHH";         User = "User-RRHH";         RelPath = "Personales\empleados\rrhh"}
)

$grupoGeneral   = "G-USUARIOS"
$grupoEmpleados  = "G-EMPLEADO"
$loginScript    = "abrir_aviso.bat"
$password       = ConvertTo-SecureString "abc123.." -AsPlainText -Force

foreach ($item in $configuracion) {
    $nombreUser = $item.User
    $ouName     = $item.OU
    # Construimos la ruta para la carpeta particular en W:
    $homeDir    = "W:\$($item.RelPath)\$nombreUser"

    $targetOU = Get-ADOrganizationalUnit -Filter "Name -eq '$ouName'"

    if ($targetOU) {
        try {
            Write-Host "--- Procesando: $nombreUser ---" -ForegroundColor Cyan
            
            # Se crea el usuario en una sola línea de comando para evitar errores de sintaxis
            New-ADUser -Name $nombreUser -SamAccountName $nombreUser -DisplayName "Usuario Base $ouName" -Enabled $true -AccountPassword $password -ChangePasswordAtLogon $true -Path $targetOU.DistinguishedName -ScriptPath $loginScript -HomeDirectory $homeDir -HomeDrive "H:" -ErrorAction Stop

            # 1. Asignar grupo específico
            Add-ADGroupMember -Identity $item.Grupo -Members $nombreUser
            Write-Host "[+] Grupo: $($item.Grupo)" -ForegroundColor Gray

            # 2. Asignar a G-EMPLEADOS si corresponde
            if ($ouName -in @("VENTAS", "CONTABILIDAD", "RRHH")) {
                Add-ADGroupMember -Identity $grupoEmpleados -Members $nombreUser
                Write-Host "[+] Grupo: $grupoEmpleados" -ForegroundColor Yellow
            }

            # 3. Asignar a grupo general
            Add-ADGroupMember -Identity $grupoGeneral -Members $nombreUser
            Write-Host "[+] Grupo: $grupoGeneral" -ForegroundColor Gray
            
            Write-Host "¡Éxito: $nombreUser configurado en W:!" -ForegroundColor Green
        }
        catch {
            Write-Warning "Error con $nombreUser : $($_.Exception.Message)"
        }
    }
    else {
        Write-Error "No se encontró la OU: $ouName"
    }
}