$nome = "prueba"

$ous = "OU=USUARIOS,OU=OFICINA,DC=OFICINA,DC=LOCAL"

Get-ADUser $nome | Move-ADObject -TargetPath $ous