# --- CONFIGURACIÓN DE RUTAS ---
$RutaBase = "V:\Compartir"
$RutaReuniones = Join-Path $RutaBase "sreuniones"

# --- DEFINICIÓN DE TIEMPOS ---
$Hoy = Get-Date
$SieteDias = $Hoy.AddDays(-7)
$UnDia = $Hoy.AddDays(-1)

# 1. BORRADO DIARIO (Sala de Reuniones)
# Borra el contenido de las carpetas privadas dentro de 'sreuniones'
if (Test-Path $RutaReuniones) {
    Get-ChildItem -Path $RutaReuniones -Recurse -File | Where-Object { 
        $_.LastWriteTime -lt $UnDia 
    } | Remove-Item -Force
}

# 2. BORRADO SEMANAL (Ventas, Contabilidad, RRHH, Avisos)
# Filtramos para EXCLUIR 'sreuniones' de este proceso para que no se duplique
$CarpetasSemanales = Get-ChildItem -Path $RutaBase -Directory | Where-Object { $_.Name -ne "sreuniones" }

foreach ($Carpeta in $CarpetasSemanales) {
    Get-ChildItem -Path $Carpeta.FullName -Recurse -File | Where-Object { 
        $_.LastWriteTime -lt $SieteDias 
    } | Remove-Item -Force
}