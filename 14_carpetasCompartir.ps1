# 1. Definir la unidad y la carpeta raíz
$rutaBase = "V:\Compartir"

# 2. Definir la estructura de carpetas
$carpetas = @(
    "ventas",
    "contabilidad\informes",
    "contabilidad\nominas",
    "rrhh",
    "avisos",
    "sreuniones"
)

# 3. Crear la ruta base si no existe
if (-not (Test-Path -Path $rutaBase)) {
    try {
        New-Item -Path $rutaBase -ItemType Directory -ErrorAction Stop | Out-Null
        Write-Host "Directorio raiz creado en V:\" -ForegroundColor Magenta
    } catch {
        Write-Host "ERROR: No se puede acceder a la unidad V:. Asegurate de que este montada." -ForegroundColor Red
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

Write-Host "`nEstructura lista en la unidad V:" -ForegroundColor Cyan


# ... (Continuación de tu script anterior)

# 5. Configurar Recursos Compartidos (SMB)
Write-Host "`nHabilitando recursos compartidos SMB..." -ForegroundColor Cyan

foreach ($carpeta in $carpetas) {
    $rutaCompleta = Join-Path -Path $rutaBase -ChildPath $carpeta
    
    # Generamos un nombre para el recurso compartido
    # Reemplazamos las barras "\" por "_" para evitar errores en nombres de red
    # Ej: "contabilidad\informes" -> "contabilidad_informes"
    $nombreRecurso = $carpeta -replace '\\', '_'

    # Verificar si el recurso ya existe para no duplicar errores
    if (-not (Get-SmbShare -Name $nombreRecurso -ErrorAction SilentlyContinue)) {
        try {
            # New-SmbShare crea el recurso en la red. 
            # -FullAccess "Everyone" otorga permisos totales en la capa de RED.
            # Nota: Los permisos reales finales dependen también de la pestaña "Seguridad" (NTFS).
            New-SmbShare -Name $nombreRecurso -Path $rutaCompleta -FullAccess "Todos" -Description "Carpeta compartida de $nombreRecurso" | Out-Null
            Write-Host "Compartido con éxito: \\$env:COMPUTERNAME\$nombreRecurso" -ForegroundColor Green
        } catch {
            Write-Host "ERROR al compartir $nombreRecurso : $_" -ForegroundColor Red
        }
    } else {
        Write-Host "El recurso '$nombreRecurso' ya está compartido." -ForegroundColor Yellow
    }
}

Write-Host "`nProceso finalizado. Puedes ver tus compartidos con 'Get-SmbShare'." -ForegroundColor Magenta