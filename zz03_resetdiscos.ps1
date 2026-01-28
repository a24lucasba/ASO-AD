Write-Host "Iniciando limpieza total de Storage Spaces..." -ForegroundColor Yellow

# 1. Borrar Discos Virtuales
Get-VirtualDisk -FriendlyName "Rapid" -ErrorAction SilentlyContinue | Remove-VirtualDisk -Confirm:$false
Get-VirtualDisk -FriendlyName "Secure" -ErrorAction SilentlyContinue | Remove-VirtualDisk -Confirm:$false

# 2. Borrar el Storage Pool
# Esto liberará los discos físicos
Get-StoragePool -FriendlyName "CompanyDataPool" -ErrorAction SilentlyContinue | Remove-StoragePool -Confirm:$false

# 3. Limpiar metadatos de los discos físicos
# A veces los discos quedan marcados como 'Retired' o con residuos, esto los resetea
Write-Host "Reseteando discos físicos..." -ForegroundColor Cyan
Get-PhysicalDisk | Where-Object { $_.CanPool -eq $false -and $_.IsSystem -eq $false } | Reset-PhysicalDisk

Write-Host "Limpieza completada. Los discos deberían estar listos para el nuevo script." -ForegroundColor Green

# Verificación
Get-PhysicalDisk -CanPool $True | Select-Object FriendlyName, Size, CanPool