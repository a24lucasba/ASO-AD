# 1. Identificar discos y separar HotSpare
$allDisks = Get-PhysicalDisk -CanPool $True
if ($allDisks.Count -lt 5) { 
    Write-Warning "Tienes $($allDisks.Count) discos. Se recomienda un mínimo de 5."
}

$hotSpareDisk = $allDisks[0]
$poolDisks = $allDisks | Where-Object { $_.DeviceId -ne $hotSpareDisk.DeviceId }
$poolName = "CompanyDataPool"

# 2. Crear el Storage Pool
Write-Host "Creando Storage Pool..." -ForegroundColor Cyan
New-StoragePool -FriendlyName $poolName -StorageSubsystemFriendlyName "Windows Storage*" -PhysicalDisks $poolDisks

# 3. Configurar el Hot Spare
Add-PhysicalDisk -StoragePoolFriendlyName $poolName -PhysicalDisks $hotSpareDisk -Usage HotSpare
Write-Host "Disco $($hotSpareDisk.DeviceId) configurado como Hot Spare." -ForegroundColor Yellow

# --- CAMBIO DE ESTRATEGIA: Primero el pequeño, luego el máximo ---

# 4. Crear el Disco VIRTUAL RAPID (400GB - Simple)
Write-Host "Creando disco RAPID (400GB)..." -ForegroundColor Blue
$vDiskRapid = New-VirtualDisk -StoragePoolFriendlyName $poolName `
    -FriendlyName "Rapid" `
    -Size 400GB `
    -ResiliencySettingName Simple `
    -NumberOfColumns 1 `
    -ProvisioningType Fixed

# 5. Crear el Disco VIRTUAL SECURE (El RESTO del espacio - Parity)
Write-Host "Creando disco SECURE (Máximo espacio restante - Parity)..." -ForegroundColor Blue
# AQUÍ ESTÁ EL TRUCO: Eliminamos el parámetro -Size por completo
$vDiskSecure = New-VirtualDisk -StoragePoolFriendlyName $poolName `
    -FriendlyName "Secure" `
    -UseMaximumSize `
    -ResiliencySettingName Parity `
    -NumberOfColumns 3 `
    -ProvisioningType Fixed

# 6. Inicializar y Formatear
Write-Host "Configurando volúmenes..." -ForegroundColor Green

if ($null -ne $vDiskRapid) {
    $vDiskRapid | Get-Disk | Initialize-Disk -PartitionStyle GPT -PassThru | `
        New-Partition -DriveLetter V -UseMaximumSize | `
        Format-Volume -FileSystem NTFS -NewFileSystemLabel "Rapid_Temp" -Confirm:$false
}

if ($null -ne $vDiskSecure) {
    $vDiskSecure | Get-Disk | Initialize-Disk -PartitionStyle GPT -PassThru | `
        New-Partition -DriveLetter W -UseMaximumSize | `
        Format-Volume -FileSystem NTFS -NewFileSystemLabel "Secure_Data" -Confirm:$false
}

Write-Host "¡Proceso finalizado!" -ForegroundColor White -BackgroundColor DarkGreen