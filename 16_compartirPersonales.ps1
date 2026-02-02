# 1. Definir variables
$ruta = "W:\datos"
$nombreCompartido = "datos$"
$descripcion = "Carpeta de datos privada"

# 2. Crear la carpeta si no existe
if (!(Test-Path $ruta)) {
    New-Item -Path $ruta -ItemType Directory
    Write-Host "Carpeta creada en $ruta" -ForegroundColor Cyan
}

# 3. Crear el recurso compartido
# Se otorgan permisos de 'Full Control' (Cambiar/Leer) a nivel de Share
New-SmbShare -Name $nombreCompartido -Path $ruta -Description $descripcion -FullAccess "Todos"

Write-Host "Recurso compartido '$nombreCompartido' creado con éxito." -ForegroundColor Green