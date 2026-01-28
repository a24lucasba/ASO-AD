# Permisos de administrador

# 1. Definir la acción: Ejecutar PowerShell con el archivo del script de limpieza
# Ajusta la ruta del archivo .ps1 a donde lo hayas guardado
$RutaScript = "C:\Scripts\LimpiezaDepartamental.ps1"
$Accion = New-ScheduledTaskAction -Execute "powershell.exe" `
    -Argument "-ExecutionPolicy Bypass -File `"$RutaScript`""

# 2. Definir el disparador: Diariamente a las 23:00 (11 PM)
# Se ejecuta diario para cubrir tanto la limpieza diaria como la semanal
$Disparador = New-ScheduledTaskTrigger -Daily -At 11pm

# 3. Definir ajustes adicionales (ejecutar aunque no haya sesión iniciada)
$Ajustes = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable

# 4. Registrar la tarea en el sistema
Register-ScheduledTask -TaskName "Mantenimiento_Compartir_Empresa" `
    -Action $Accion `
    -Trigger $Disparador `
    -Settings $Ajustes `
    -User "SYSTEM" `
    -RunLevel Highest `
    -Force

Write-Host "Tarea programada creada con éxito. Se ejecutará bajo la cuenta SYSTEM." -ForegroundColor Green