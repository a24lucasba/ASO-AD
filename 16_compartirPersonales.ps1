# 1. Configuración de Rutas
$rutaBase = "W:\"

# 2. Definición de los Shares (Relativa -> Nombre del Recurso)
$recursosCompartidos = @{
    "datos\empleados\ventas"    = "ventas"
    "datos\empleados\contabilidad"    = "contabilidad"
    "datos\empleados\rrhh"    = "rrhh"
    "datos\jefes"        = "jefes"
    "datos\informaticos" = "informaticos"
    "sreuniones"         = "Salas_Reuniones"
}

# 3. Verificación de la unidad raíz
if (-not (Test-Path -Path $rutaBase)) {
    Write-Host "ERROR: La unidad $rutaBase no existe. Monta el disco antes de continuar." -ForegroundColor Red
    return
}

# 4. Bucle de creación de recursos compartidos
Write-Host "Iniciando configuración de SMB Shares..." -ForegroundColor Cyan

foreach ($relativa in $recursosCompartidos.Keys) {
    $nombreShare = $recursosCompartidos[$relativa]
    # Join-Path ahora recibirá $rutaBase correctamente
    $rutaCompleta = Join-Path -Path $rutaBase -ChildPath $relativa

    # Verificar si la carpeta física existe antes de compartirla
    if (Test-Path -Path $rutaCompleta) {
        if (-not (Get-SmbShare -Name $nombreShare -ErrorAction SilentlyContinue)) {
            try {
                New-SmbShare -Name $nombreShare -Path $rutaCompleta -FullAccess "Todos" -ErrorAction Stop
                Write-Host "EXITO: Compartido '$nombreShare' en $rutaCompleta" -ForegroundColor Green
            } catch {
                Write-Host "ERROR al compartir $nombreShare : $($_.Exception.Message)" -ForegroundColor Red
            }
        } else {
            Write-Host "AVISO: El recurso '$nombreShare' ya estaba compartido." -ForegroundColor Yellow
        }
    } else {
        Write-Host "ERROR: La carpeta física $rutaCompleta no existe. Créala primero." -ForegroundColor Red
    }
}