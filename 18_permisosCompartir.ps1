# Definición de la ruta base
$rutaBase = "V:\Compartir"

Write-Host "--- Aplicando Permisos ICACLS en $rutaBase ---" -ForegroundColor Cyan

# 1. Permisos en la Raíz (V:\Compartir)
# Quitamos herencia y damos acceso total a Admins y lectura a todos los usuarios (G-Usuarios)
icacls "$rutaBase" /inheritance:r /grant "Administradores:(OI)(CI)F" "Usuarios:(OI)(CI)RX"

# 2. V:\Compartir\ventas
icacls "$rutaBase\ventas" /grant "G-Ventas:(OI)(CI)M" "CREATOR OWNER:(OI)(CI)(IO)F"

# 3. V:\Compartir\contabilidad (Carpeta contenedora)
icacls "$rutaBase\contabilidad" /grant "G-Contabilidad:(OI)(CI)RX"

# 4. V:\Compartir\contabilidad\informes
icacls "$rutaBase\contabilidad\informes" /grant "G-Contabilidad:(OI)(CI)M" "CREATOR OWNER:(OI)(CI)(IO)F"

# 5. V:\Compartir\contabilidad\nominas
# Permisos más restrictivos: Solo lectura para el grupo, modificación solo para el creador
icacls "$rutaBase\contabilidad\nominas" /grant "G-Contabilidad:(OI)(CI)RX" "G-Jefes:(OI)(CI)M"

# 6. V:\Compartir\rrhh
# Quitamos herencia para que nadie fuera de RRHH y Admins vea el contenido
icacls "$rutaBase\rrhh" /inheritance:r /grant "Administradores:(OI)(CI)F" "G-RRHH:(OI)(CI)M" "CREATOR OWNER:(OI)(CI)(IO)F"

# 7. V:\Compartir\avisos
# Acceso de lectura para todos, pero modificación para un grupo de comunicación
icacls "$rutaBase\avisos" /grant "Usuarios:(OI)(CI)RX" "G-Jefes:(OI)(CI)M"

# 8. V:\Compartir\sreuniones
icacls "$rutaBase\sreuniones" /inheritance:r /grant "Administradores:(OI)(CI)F" "Usuarios:(OI)(CI)RX" "CREATOR OWNER:(OI)(CI)(IO)F"

Write-Host "`nEstructura de permisos NTFS aplicada correctamente." -ForegroundColor Green