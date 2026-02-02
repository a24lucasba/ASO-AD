# 1. Definir la unidad y la carpeta raíz
$rutaBase = "W:\"

# 2. Definir la estructura de carpetas
$carpetas = @(
    "datos\empleados\ventas",
    "datos\empleados\contabilidad",
    "datos\empleados\rrhh",
    "datos\jefes",
    "datos\informaticos",
    "perfiles"
)

# 3. Crear la ruta base si no existe
if (-not (Test-Path -Path $rutaBase)) {
    try {
        New-Item -Path $rutaBase -ItemType Directory -ErrorAction Stop | Out-Null
        Write-Host "Directorio raiz creado en W:\" -ForegroundColor Magenta
    } catch {
        Write-Host "ERROR: No se puede acceder a la unidad W:. Asegurate de que este montada." -ForegroundColor Red
        return
    }
}

# 4. Crear las subcarpetas
foreach ($carpeta in $carpetas) {
    $rutaCompleta = Join-Path -Path $rutaBase -ChildPath $carpeta
    
    if (-not (Test-Path -Path $rutaCompleta)) {
        New-Item -Path $rutaCompleta -ItemType Directory -Force | Out-Null
        Write-Host "Creado: $carpeta" -ForegroundColor Green
    } else {
        Write-Host "Existente: $carpeta" -ForegroundColor Yellow
    }
}

Write-Host "`nEstructura lista en la unidad W:" -ForegroundColor Cyan