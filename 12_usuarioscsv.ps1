# Importar el módulo de Active Directory
Import-Module ActiveDirectory

# Obtener el nombre del dominio una sola vez para eficiencia
$DomainDNS = (Get-ADDomain).DNSRoot

# Importar el CSV
$usuarios = Import-Csv -Path "usuarios.csv" -Delimiter ","

foreach ($fila in $usuarios) {
    $nuevoSAM = $fila.Usuario
    $baseSAM = $fila.UsuarioBase
    $nombre = $fila.Nombre
    $apellidos = $fila.Apellidos
    $displayName = "$nombre $apellidos"
    
    Write-Host "`n>>> Clonando en AD: [$baseSAM] -> [$nuevoSAM]" -ForegroundColor Cyan

    # 1. Obtener datos del usuario BASE
    $userBaseObj = Get-ADUser -Identity $baseSAM -Properties MemberOf, DistinguishedName -ErrorAction SilentlyContinue
    if (-not $userBaseObj) {
        Write-Warning "El usuario base [$baseSAM] no existe. Saltando..."
        continue
    }

    # 2. Obtener la OU del usuario base (para crear al nuevo en el mismo sitio)
    # Extraemos la ruta quitando el CN=... inicial
    $targetOU = $userBaseObj.DistinguishedName.Substring($userBaseObj.DistinguishedName.IndexOf(",") + 1)
    
    # 3. Crear el nuevo usuario
    if (Get-ADUser -Filter "SamAccountName -eq '$nuevoSAM'") {
        Write-Warning "El usuario [$nuevoSAM] ya existe."
    }
    else {
        try {
            $pass = ConvertTo-SecureString "Temporal.2026!" -AsPlainText -Force

            # Creamos el usuario cambiando solo los datos de identidad
            New-ADUser -Name $displayName `
                -SamAccountName $nuevoSAM `
                -UserPrincipalName "$nuevoSAM@$DomainDNS" `
                -GivenName $nombre `
                -Surname $apellidos `
                -DisplayName $displayName `
                -Path $targetOU `
                -AccountPassword $pass `
                -Enabled $true `
                -ChangePasswordAtLogon $true `
                -ErrorAction Stop

            Write-Host " + Cuenta creada en OU: $targetOU" -ForegroundColor Green

            # 4. Clonar grupos (excepto el grupo principal 'Domain Users')
            foreach ($grupoDN in $userBaseObj.MemberOf) {
                Add-ADGroupMember -Identity $grupoDN -Members $nuevoSAM -ErrorAction SilentlyContinue
            }
            Write-Host " + Grupos clonados correctamente." -ForegroundColor Gray

        }
        catch {
            Write-Host " X Error al crear [$nuevoSAM]: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}