# =================================================================
# SCRIPT COMPLETO: CONFIGURACIÓN E INCLUSIÓN EN DOMINIO (CLIENTE)
# =================================================================

# --- 1. VARIABLES DE CONFIGURACIÓN ---
$nuevoNombre = "CLIENTE-01"
$dominio     = "oficina.local"
$user        = "Administrador"

# Configuración de Red
$nic         = "Ethernet"       # Nombre del adaptador (ver con Get-NetAdapter)
$ipCliente   = "172.16.10.210"  # IP única para este cliente
$prefijo     = 24               # Máscara 255.255.255.0
$puertaEnlace = "172.16.10.1"
$dnsServidor = "172.16.10.200"  # IP del DC 'dnsserver'

Write-Host "--- Iniciando configuración del cliente ---" -ForegroundColor Cyan

# --- 2. CONFIGURACIÓN DE RED (IP Y DNS) ---
Write-Host "Configurando IP estática y DNS..." -ForegroundColor Gray
# Limpiar configuración previa si existe
Remove-NetIPAddress -InterfaceAlias $nic -Confirm:$false 2> $null
Remove-NetRoute -InterfaceAlias $nic -Confirm:$false 2> $null

# Asignar nueva IP y DNS
New-NetIPAddress -InterfaceAlias $nic -IPAddress $ipCliente -PrefixLength $prefijo -DefaultGateway $puertaEnlace
Set-DnsClientServerAddress -InterfaceAlias $nic -ServerAddresses $dnsServidor

# --- 3. CAMBIO DE NOMBRE Y UNIÓN AL DOMINIO ---
# Nota: Hacemos ambas cosas en un solo comando para minimizar reinicios
Write-Host "Solicitando credenciales de dominio..." -ForegroundColor Yellow
$credential = Get-Credential -UserName "$dominio\$user" -Message "Introduce credenciales de $dominio"

try {
    Write-Host "Cambiando nombre a $nuevoNombre y uniéndose al dominio..." -ForegroundColor Gray
    
    # Este comando cambia el nombre y une al dominio simultáneamente
    Add-Computer -DomainName $dominio -NewName $nuevoNombre -Credential $credential -Restart -Force
}
catch {
    Write-Error "Error en el proceso: $($_.Exception.Message)"
}