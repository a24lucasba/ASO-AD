# 1. Crear el recurso compartido con permisos de Cambio para "Todos"
New-SmbShare -Name "Compartir$" -Path "V:\Compartir" -FullAccess "Todos"

# 2. Ajustar permisos de seguridad (NTFS) para que sea accesible
$acl = Get-Acl "V:\Compartir"
$permission = "Todos","Modify","Allow"
$accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule $permission
$acl.SetAccessRule($accessRule)
Set-Acl "V:\Compartir" $acl

Write-Host "Carpeta V:\Compartir compartida exitosamente." -ForegroundColor Green