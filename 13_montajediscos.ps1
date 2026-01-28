# 1. Identificar discos físicos
$disks = Get-PhysicalDisk -CanPool $True
$poolName = "CompanyDataPool"

# 2. Crear el Storage Pool
Write-Host "Creando Storage Pool: $poolName..." -ForegroundColor Cyan
New-StoragePool -FriendlyName $poolName -StorageSubsystemFriendlyName "Windows Storage*" -PhysicalDisks $disks

# 3. Crear el Disco VIRTUAL SECURE (Parity)
Write-Host "Creando disco SECURE (1.2TB - Parity)..." -ForegroundColor Blue
$vDiskSecure = New-VirtualDisk -StoragePoolFriendlyName $poolName `
    -FriendlyName "Secure" `
    -Size 1.2TB `
    -ResiliencySettingName Parity `
    -ProvisioningType Fixed `
    -WriteCacheSize 0

# 4. Crear el Disco VIRTUAL RAPID (Simple)
Write-Host "Creando disco RAPID (400GB - Simple)..." -ForegroundColor Blue
$vDiskRapid = New-VirtualDisk -StoragePoolFriendlyName $poolName `
    -FriendlyName "Rapid" `
    -Size 400GB `
    -ResiliencySettingName Simple `
    -ProvisioningType Fixed `
    -WriteCacheSize 0

# 5. Inicializar y Formatear con letras específicas
Write-Host "Configurando volúmenes con letras W y V..." -ForegroundColor Green

# Configurar Secure -> Letra W
$vDiskSecure | Get-Disk | Initialize-Disk -PartitionStyle GPT -PassThru | `
    New-Partition -DriveLetter W -UseMaximumSize | `
    Format-Volume -FileSystem NTFS -NewFileSystemLabel "Secure_Data" -Confirm:$false

# Configurar Rapid -> Letra V
$vDiskRapid | Get-Disk | Initialize-Disk -PartitionStyle GPT -PassThru | `
    New-Partition -DriveLetter V -UseMaximumSize | `
    Format-Volume -FileSystem NTFS -NewFileSystemLabel "Rapid_Temp" -Confirm:$false

Write-Host "¡Proceso finalizado!" -ForegroundColor White -BackgroundColor DarkGreen

# Resumen final
Get-VirtualDisk | Select-Object FriendlyName, Size, HealthStatus
Get-Volume | Where-Object { $_.DriveLetter -in 'W','V' } | Select-Object DriveLetter, FileSystemLabel, Size