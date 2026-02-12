
$rutaBase = "W:\datos"

Write-Host "--- Aplicando Permisos Específicos según Requerimientos ---" -ForegroundColor Cyan

icacls "$rutaBase" /inheritance:r /grant "Administradores:(OI)(CI)F" "G-Usuarios:RX"

icacls "$rutaBase\empleados"  /grant "Administradores:(OI)(CI)F" "G-Empleados:RX" "G-Jefes:RX"

icacls "$rutaBase\empleados\ventas"  /grant "Administradores:(OI)(CI)F" "G-Ventas:RX" "G-Jefes:(OI)(CI)RX"

icacls "$rutaBase\empleados\contabilidad"  /grant "Administradores:(OI)(CI)F" "G-Contabilidad:RX" "G-Jefes:(OI)(CI)RX"

icacls "$rutaBase\empleados\rrhh"  /grant "Administradores:(OI)(CI)F" "G-RRHH:RX"

icacls "$rutaBase\jefes"  /grant "Administradores:(OI)(CI)F" "G-Jefes:RX"

icacls "$rutaBase\informaticos"  /grant "Administradores:(OI)(CI)F" "G-Informaticos:RX"





Write-Host "`nPermisos NTFS configurados." -ForegroundColor Magenta