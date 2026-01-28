# =================================================================
# SCRIPT DE CREACIÓN Y ANIDACIÓN DE GRUPOS (SEGÚN IMAGEN)
# =================================================================

# 1. Definir la lista de grupos, su ubicación y su "padre" para la anidación
# Estructura: NombreGrupo, OU_Destino, Padre (miembro de)
$jerarquiaGrupos = @(
    @{Nombre="G-USUARIOS";      OU="USUARIOS";    Padre=$null},
    @{Nombre="G-JEFES";         OU="JEFES";       Padre="G-USUARIOS"},
    @{Nombre="G-EMPLEADOS";      OU="EMPLEADOS";   Padre="G-USUARIOS"},
    @{Nombre="G-INFORMATICOS";  OU="INFORMATICOS";Padre="G-USUARIOS"},
    @{Nombre="G-VENTAS";        OU="VENTAS";      Padre="G-EMPLEADO"},
    @{Nombre="G-CONTABILIDAD";  OU="CONTABILIDAD";Padre="G-EMPLEADO"},
    @{Nombre="G-RRHH";          OU="RRHH";        Padre="G-EMPLEADO"}
)

foreach ($g in $jerarquiaGrupos) {
    $nombre = $g.Nombre
    $ouName = $g.OU
    $padre  = $g.Padre
    $desc   = "Grupo $nombre - Dominio oficina.local"

    # A. Buscar la OU de destino (creadas con el script anterior)
    $targetOU = Get-ADOrganizationalUnit -Filter "Name -eq '$ouName'"

    if ($targetOU) {
        # B. Crear el grupo si no existe
        try {
            Write-Host "Creando grupo: $nombre en OU: $ouName..." -ForegroundColor Cyan
            New-ADGroup -Name $nombre -SamAccountName $nombre `
                        -GroupCategory Security -GroupScope Global `
                        -DisplayName $nombre -Path $targetOU.DistinguishedName `
                        -Description $desc -ErrorAction Stop
        }
        catch {
            Write-Warning "El grupo $nombre ya existe o no se pudo crear."
        }

        # C. Anidación: Si tiene un padre definido, lo añadimos
        if ($padre) {
            try {
                Write-Host "Anidando $nombre dentro de $padre..." -ForegroundColor Gray
                Add-ADGroupMember -Identity $padre -Members $nombre -ErrorAction SilentlyContinue
            }
            catch {
                Write-Warning "No se pudo anidar $nombre en $padre."
            }
        }
    }
    else {
        Write-Error "No se encontró la OU: $ouName para el grupo $nombre"
    }
}

Write-Host "`nEstructura de grupos completada según la imagen." -ForegroundColor Green