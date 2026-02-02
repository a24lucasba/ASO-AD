# Definición de la ruta base
$rutaBase = "V:\Compartir"

Write-Host "--- Aplicando Permisos ICACLS en $rutaBase ---" -ForegroundColor Cyan

icacls "$rutaBase" /inheritance:r /grant "Administradores:(OI)(CI)F" "G-Usuarios:RX"

icacls "$rutaBase\avisos" /grant "Administradores:(OI)(CI)F" "G-Jefes:(OI)(CI)M"

icacls "$rutaBase\contabilidad" /inheritance:r /grant "Administradores:(OI)(CI)F" "G-Empleados:(OI)(CI)RX" "G-Jefes:RX"

icacls "$rutaBase\contabilidad\informes" /grant "Administradores:(OI)(CI)F" "G-Contabilidad:(OI)(CI)(IO)W" "G-Ventas:(OI)(CI)(IO)W"

icacls "$rutaBase\contabilidad\nominas" /grant "Administradores:(OI)(CI)F" "G-Contabilidad:(OI)(CI)(IO)W" "G-Jefes:(OI)(CI)(IO)W"

icacls "$rutaBase\ventas" /inheritance:r /grant "Administradores:(OI)(CI)F" "G-Jefes:W" "G-Ventas:W"

Write-Host "`nEstructura de permisos NTFS aplicada." -ForegroundColor Green