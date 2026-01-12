# Script de instalación de Active Directory basado en DeploymentConfigTemplate.xml
# Ejecutar con privilegios de Administrador

# 1. Definir la lista de características extraídas del XML
$features = @(
    "AD-Domain-Services",  # ID: 10
    "DNS",                 # ID: 13
    "GPMC",                # ID: 69
    "RSAT",                # ID: 67
    "RSAT-AD-AdminCenter", # ID: 330
    "RSAT-AD-PowerShell",  # ID: 331
    "RSAT-AD-Tools",       # ID: 329
    "RSAT-ADDS",           # ID: 257
    "RSAT-ADDS-Tools",     # ID: 299
    "RSAT-DNS-Server",     # ID: 273
    "RSAT-Role-Tools"      # ID: 256
)

Write-Host "Iniciando la instalación de componentes para Active Directory..." -ForegroundColor Cyan

# 2. Instalar los roles y características
foreach ($feature in $features) {
    Write-Host "Instalando: $feature..." -ForegroundColor Gray
    Install-WindowsFeature -Name $feature -IncludeAllSubFeature -IncludeManagementTools
}

Write-Host "`nLos componentes base han sido instalados correctamente." -ForegroundColor Green

# 3. Importar el módulo de despliegue de ADDS
Import-Module ADDSDeployment

Write-Host "-----------------------------------------------------------------------"
Write-Host "PASO SIGUIENTE: Configuración del Dominio" -ForegroundColor Yellow
Write-Host "Los binarios están instalados, pero el servidor aún no es un DC."
Write-Host "Para finalizar, debe ejecutar 'Install-ADDSForest' o 'Install-ADDSDomainController'."
Write-Host "-----------------------------------------------------------------------"