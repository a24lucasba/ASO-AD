# 1. Definir la raíz del dominio
$domain = "DC=OFICINA,DC=LOCAL"

# 2. Definir la estructura jerárquica
$arbolOUs = @{
    "OFICINA" = @{
        "USUARIOS" = @{
            "EMPLEADOS"    = @("VENTAS", "CONTABILIDAD", "RRHH")
            "JEFES"        = @()
            "INFORMATICOS" = @()
        }
        "EQUIPOS" = @{
            "CLIENTES" = @{
                "ZONATRABAJO"   = @()
                "SALAREUNIONES" = @()
                "ANEXO"         = @("DPRRHH", "DPIT")
            }
            "SERVIDORES" = @("DC", "OTROS")
        }
        "IMPRESORAS" = @()
    }
}

# 3. Función recursiva optimizada
function crearOU($lasOUs, $ouRaiz) {
    # Caso A: Si es una Tabla Hash (un diccionario con subcarpetas)
    if ($lasOUs -is [System.Collections.Hashtable]) {
        foreach ($ou in $lasOUs.Keys) {
            $nuevaOU_DN = "OU=$ou,$ouRaiz"
            Write-Host "Creando OU Contenedora: $nuevaOU_DN" -ForegroundColor Cyan
            
            # Crear la OU actual
            New-ADOrganizationalUnit -Name $ou -Path $ouRaiz -ProtectedFromAccidentalDeletion $false -ErrorAction SilentlyContinue
            
            # Llamada recursiva para procesar lo que hay dentro de esta clave
            crearOU $lasOUs.$ou $nuevaOU_DN
        }
    }
    # Caso B: Si es un Array (una lista de OUs finales)
    elseif ($lasOUs -is [System.Array]) {
        foreach ($ou in $lasOUs) {
            Write-Host "Creando OU Final: OU=$ou,$ouRaiz" -ForegroundColor Gray
            New-ADOrganizationalUnit -Name $ou -Path $ouRaiz -ProtectedFromAccidentalDeletion $false -ErrorAction SilentlyContinue
        }
    }
}

# 4. Ejecución del script
Write-Host "Iniciando creación de estructura de OUs en $domain..." -ForegroundColor Yellow
crearOU $arbolOUs $domain
Write-Host "Proceso finalizado." -ForegroundColor Green