Set-DnsServerPrimaryZone -Name "oficina.local" -ReplicationScope "Domain" -PassThru

Add-DnsServerForwarder -IPAddress @("8.8.8.8","8.8.4.4") -PassThru #Reenviadores