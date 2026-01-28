# Importar el CSV
$usuarios = Import-Csv -Path "usuarios.csv" -Delimiter ","

Write-Host "Iniciando proceso de borrado de usuarios..." -ForegroundColor Yellow
Write-Host "------------------------------------------------"

foreach ($fila in $usuarios) {
    $usuarioABorrar = $fila.Usuario

    # 1. Verificar si el usuario existe antes de intentar borrar
    if (Get-LocalUser -Name $usuarioABorrar -ErrorAction SilentlyContinue) {
        try {
            # 2. Eliminar el usuario
            Remove-LocalUser -Name $usuarioABorrar -Confirm:$false -ErrorAction Stop
            
            Write-Host "[-] Usuario [$usuarioABorrar] eliminado correctamente." -ForegroundColor Green
            
            # 3. Nota sobre el perfil (C:\Users\...)
            # Remove-LocalUser borra la cuenta, pero a veces Windows mantiene la carpeta.
            # El siguiente comando intenta limpiar el perfil del sistema.
            $perfil = Get-WmiObject -Class Win32_UserProfile | Where-Object { $_.LocalPath -like "*\$usuarioABorrar" }
            if ($perfil) {
                $perfil.Delete()
                Write-Host "    > Carpeta de perfil eliminada." -ForegroundColor Gray
            }
        } catch {
            Write-Host " [!] Error al borrar [$usuarioABorrar]: $($_.Exception.Message)" -ForegroundColor Red
        }
    } else {
        Write-Host " [?] El usuario [$usuarioABorrar] no existe o ya fue borrado." -ForegroundColor DarkGray
    }
}

Write-Host "------------------------------------------------"
Write-Host "Proceso de limpieza finalizado." -ForegroundColor Cyan