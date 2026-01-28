# =================================================================
# SCRIPT DE CREACIÓN DE USUARIOS - VERSIÓN CORREGIDA
# =================================================================

$configuracion = @(
    @{Grupo = "G-JEFES"; OU = "JEFES"; User = "User-Jefes" },
    @{Grupo = "G-INFORMATICOS"; OU = "INFORMATICOS"; User = "User-IT" },
    @{Grupo = "G-VENTAS"; OU = "VENTAS"; User = "User-Ventas" },
    @{Grupo = "G-CONTABILIDAD"; OU = "CONTABILIDAD"; User = "User-Contabilidad" },
    @{Grupo = "G-RRHH"; OU = "RRHH"; User = "User-RRHH" }
)

$grupoGeneral = "G-USUARIOS"
$password = ConvertTo-SecureString "abc123.." -AsPlainText -Force

foreach ($item in $configuracion) {
    $nombreUser = $item.User
    $ouName = $item.OU
    $grupoEspecifico = $item.Grupo

    $targetOU = Get-ADOrganizationalUnit -Filter "Name -eq '$ouName'"

    if ($targetOU) {
        try {
            Write-Host "--- Procesando: $nombreUser ---" -ForegroundColor Cyan
            
            # Se eliminaron los acentos graves (`) para evitar errores de espacios invisibles
            New-ADUser -Name $nombreUser -SamAccountName $nombreUser -DisplayName "Usuario Base $ouName" -Enabled $true -AccountPassword $password -ChangePasswordAtLogon $true -Path $targetOU.DistinguishedName -ErrorAction Stop

            Add-ADGroupMember -Identity $grupoEspecifico -Members $nombreUser
            Write-Host "[+] Asignado a $grupoEspecifico" -ForegroundColor Gray

            Add-ADGroupMember -Identity $grupoGeneral -Members $nombreUser
            Write-Host "[+] Asignado a $grupoGeneral" -ForegroundColor Gray
            
            Write-Host "¡Usuario $nombreUser creado y configurado con éxito!" -ForegroundColor Green
        }
        catch {
            # CORRECCIÓN: Se metieron los dos puntos dentro de las comillas para evitar el error de parámetro
            Write-Warning "Error con $nombreUser : $($_.Exception.Message)" 
        }
    }
    else {
        Write-Error "No se encontró la OU: $ouName"
    }
}