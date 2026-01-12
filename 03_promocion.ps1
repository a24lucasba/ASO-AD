# Script optimizado para la promoción
Import-Module ADDSDeployment

# Definir la contraseña de DSRM como un Secure String para que no de error
$Password = Read-Host -Prompt "Introduce la contraseña para DSRM (Modo Restauración)" -AsSecureString

Install-ADDSForest `
-CreateDnsDelegation:$false `
-DatabasePath "C:\WINDOWS\NTDS" `
-DomainMode "WinThreshold" `
-DomainName "oficina.local" `
-DomainNetbiosName "OFICINA" `
-ForestMode "WinThreshold" `
-InstallDns:$true `
-LogPath "C:\WINDOWS\NTDS" `
-NoRebootOnCompletion:$false `
-SysvolPath "C:\WINDOWS\SYSVOL" `
-SafeModeAdministratorPassword $Password `
-Force:$true

