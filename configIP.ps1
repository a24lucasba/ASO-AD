#Buscamos el nombre del adaptador a configurar
#Get-NetAdapter #Una vez que lo tenemos claro...
$nombre = "dnsserver"
$nic = "Ethernet"
$ip = "172.16.10.200"
$ms = 24
$pe = "172.16.10.1"
$dnsServers = @("127.0.0.1")
$dnsSuffix = @("oficina.local")
# Deshabilitamos el DHCP si fuese necesario
Set-NetIPInterface -InterfaceAlias $nic -DHCP Disabled
# Eliminamos la configuración IP del equipo si ésta ya existe
Remove-NetIPAddress -InterfaceAlias $nic -IncludeAllCompartments `
-Confirm:$false 2> $null
# Eliminamos la configuración de la Puerta de Enlace si ésta ya existe
Remove-NetRoute -InterfaceAlias $nic -Confirm:$false 2> $null
# Configuramos la IP estática, la máscara de subred y la puerta de enlace
New-NetIPAddress -InterfaceAlias $nic -AddressFamily IPv4 -IPAddress $ip `
-PrefixLength $ms -Type Unicast -DefaultGateway $pe
# Configuramos los servidores DNS
Set-DnsClientServerAddress -InterfaceAlias $nic -ServerAddresses $dnsServers
# Anexar sufijo DNS
Set-DnsClientGlobalSetting -SuffixSearchList $dnsSuffix
#Habilitar pings
New-NetFirewallRule -name 'ICMPv4' -DisplayName 'ICMPv4' `
-Description 'Allow ICMPv4' -Profile Any -Direction Inbound -Action Allow `
-Protocol ICMPv4 -IcmpType 8 -Program Any -LocalAddress Any -RemoteAddress Any
#Para cambiar el nombre al equipo – El equipo se reinicia automáticamente
Rename-Computer -NewName $nombre -Restart -Force