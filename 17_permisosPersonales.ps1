# Definición de la ruta base
$rutaBase = "V:\Compartir"

Write-Host "--- Aplicando Permisos Específicos según Requerimientos ---" -ForegroundColor Cyan

# 1. COMPARTIR/ventas (Intercambio Ventas y Jefe)
# G-Ventas y G-Jefe pueden leer y escribir.
icacls "$rutaBase\ventas" /inheritance:r /grant "Administradores:(OI)(CI)F" "G-Ventas:(OI)(CI)M" "G-Jefe:(OI)(CI)M"

# 2. COMPARTIR/contabilidad/informes (Ventas y Contabilidad)
icacls "$rutaBase\contabilidad\informes" /inheritance:r /grant "Administradores:(OI)(CI)F" "G-Ventas:(OI)(CI)M" "G-Contabilidad:(OI)(CI)M"

# 3. COMPARTIR/contabilidad/nominas (Ventas y Jefe)
icacls "$rutaBase\contabilidad\nominas" /inheritance:r /grant "Administradores:(OI)(CI)F" "G-Ventas:(OI)(CI)M" "G-Jefe:(OI)(CI)M"

# 4. COMPARTIR/rrhh (RRHH y Jefe)
icacls "$rutaBase\rrhh" /inheritance:r /grant "Administradores:(OI)(CI)F" "G-RRHH:(OI)(CI)M" "G-Jefe:(OI)(CI)M"

# 5. COMPARTIR/avisos (Jefe publica, Empleados leen)
# G-Jefe: Modificar (M) | Usuarios: Solo lectura (RX)
icacls "$rutaBase\avisos" /inheritance:r /grant "Administradores:(OI)(CI)F" "G-Jefe:(OI)(CI)M" "G-Usuarios:(OI)(CI)RX"

# 6. COMPARTIR/sreuniones (Carpeta privada para enviar archivos)
# Los usuarios pueden entrar (RX), pero usamos CREATOR OWNER para que cada uno 
# solo vea/gestione lo que él mismo crea.
icacls "$rutaBase\sreuniones" /inheritance:r /grant "Administradores:(OI)(CI)F" "G-Usuarios:(OI)(CI)RX" "CREATOR OWNER:(OI)(CI)F"

Write-Host "`nPermisos NTFS configurados. Procediendo a crear tareas de limpieza..." -ForegroundColor Magenta