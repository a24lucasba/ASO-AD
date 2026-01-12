$empleados = @(
    @{Nombre="prueba"; Apellido="pruebez"}
)

# Definimos la contraseña una sola vez fuera del bucle para mayor eficiencia
$password = ConvertTo-SecureString "abc123.." -AsPlainText -Force

foreach ($e in $empleados) {
    # 1. Extraer los datos del empleado actual del array
    $usuario     = $e.Nombre     # Toma el valor de "Nombre" en el array
    $apellido    = $e.Apellido   # Toma el valor de "Apellido" en el array
    $displayName = "$usuario $apellido"

    Write-Host "Creando el usuario: $displayName..." -ForegroundColor Cyan

    # 2. Crear el usuario usando las variables dinámicas
    try {
        New-ADUser -Name $displayName `
                -SamAccountName $usuario `
                -GivenName $usuario `
                -Surname $apellido `
                -DisplayName $displayName `
                -Enabled $true `
                -AccountPassword $password `
                -ChangePasswordAtLogon $false `
                -Path "CN=Users,DC=oficina,DC=local" 

        Write-Host "¡Usuario '$usuario' creado con éxito!" -ForegroundColor Green
    }
    catch {
        Write-Warning "No se pudo crear a $usuario. Error: $($_.Exception.Message)"
    }
}