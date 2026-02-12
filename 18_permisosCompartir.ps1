# Definición de la ruta base
$rutaBase = "V:\Compartir"

Write-Host "--- Aplicando Permisos ICACLS en $rutaBase ---" -ForegroundColor Cyan

icacls "$rutaBase" /inheritance:r /grant "Administradores:(OI)(CI)F" "G-Usuarios:RX"

icacls "$rutaBase\avisos" /grant "Administradores:(OI)(CI)F" "G-Jefes:(OI)(CI)M" "G-Usuarios:RX"

icacls "$rutaBase\contabilidad" /inheritance:r /grant "Administradores:(OI)(CI)F" "G-Empleados:RX" "G-Jefes:RX"

icacls "$rutaBase\contabilidad\informes" /grant "Administradores:(OI)(CI)F" "G-Contabilidad:(OI)(CI)W" "G-Ventas:(OI)(CI)W"

icacls "$rutaBase\contabilidad\nominas" /grant "Administradores:(OI)(CI)F" "G-Contabilidad:(OI)(CI)W" "G-Jefes:(OI)(CI)W"

icacls "$rutaBase\ventas" /inheritance:r /grant "Administradores:(OI)(CI)F" "G-Jefes:(OI)(CI)W" "G-Ventas:(OI)(CI)W"

icacls "$rutaBase\sreuniones" /inheritance:r /grant "Administradores:(OI)(CI)F" "G-Jefes:(OI)(CI)W" "G-Empleados:(OI)(CI)W"

Write-Host "`nEstructura de permisos NTFS aplicada." -ForegroundColor Green