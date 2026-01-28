#!/bin/python3
#Script que agrega discos duros a VirtualBox
#Se utiliza la herramienta VboxManage que puede ejecutar cualquier usuario del sistema

# 5 de 500

from subprocess import call

##Función ejecutaComando(comando)####
def ejecutaComando(comando):
    from subprocess import PIPE, Popen
    import re

    proceso = Popen(comando, shell=True, stdout=PIPE, stderr=PIPE)
    error_encontrado = proceso.stderr.read()
    salidaComando = proceso.stdout.read().decode('utf-8').strip()
    proceso.stdout.close()

    if not error_encontrado:
        return salidaComando
    else:
        return error_encontrado
#####################################


#Buscamos la máquina a la que queremos agregar los discos
cmdMaquinas = "/usr/bin/VBoxManage list vms"
#La salida de este comando tiene la forma siguiente :
##"Windows 2019 08-01-2020" {16718d20-ac52-494f-83da-c579e389bd76}
##"Windows 10 08-01-2020" {e880ecac-9f61-451b-a987-d7b81b3f4dba}
#Creamos una lista de máquinas:
salidaCmdMaquinas = ejecutaComando(cmdMaquinas)
# print(listaMaquinas)

listaMaquinas = []
print("Las máquinas existentes en tu equipo son : ")
n = 1 #Para ir mostrando la lista de las máquinas
for maquina in salidaCmdMaquinas.split('\n'):
    m = maquina.split()[0].strip('"')
    print("\t{}.- {}".format(n,m))
    n+=1
    listaMaquinas.append(m)
#print(listaMaquinas)

numMaquina = int(input("\nIndica en qué máquina quieres añadir los discos - Introduce número: ")) - 1
if numMaquina >= 0 and numMaquina < len(listaMaquinas):
    maquinaTrabajo = listaMaquinas[numMaquina]
    print("La máquina seleccionada es : " + maquinaTrabajo)
else:
    print("Esa máquina NO existe")
# $maquinaTrabajo = "Windows 2019 08-01-2020"

#Directorio archivos máquina de trabajo
cmdInfoMaquina = "/usr/bin/VBoxManage showvminfo {}".format(maquinaTrabajo)
infoMaquina = ejecutaComando(cmdInfoMaquina)
# print(infoMaquina)
for linea in infoMaquina.split('\n'):
    if linea.startswith('Config file'):
        # print(linea)
        directorioMaquina = "/".join(linea.split(':')[1].strip().split('/')[:-1])+'/'
# print(directorioMaquina)
# # directorioMaquina = "/home/ladmin/VirtualBox VMs/Windows2022_SL_ALMACEN/"

#Número de discos a crear
numDiscos = int(input("\nNº de discos que quieres crear: "))
# print(numDiscos)

#Tamaño discos en GB
tamDiscos = int(input("\nTamaño de los discos a crear en GB: "))
tamDiscosMiB = 1024 * tamDiscos
# print(tamDiscosMiB)

#Tipo de controladora, a crear si fuese necesario
tipoControladora = 'SAS'
print("\nCrearemos {} discos de {} GiB conectados por {} ".format(numDiscos,tamDiscos,tipoControladora),end="")
print("en la máquina {}.\n".format(maquinaTrabajo))

#Agregamos la controladora SAS a la máquina
cmdNuevaControladora = "/usr/bin/VBoxManage storagectl {} --name {} --add {}".\
    format(maquinaTrabajo,tipoControladora,tipoControladora)
# print(cmdNuevaControladora)
call(cmdNuevaControladora, shell=True)
#Configuramos la controladora SAS para añadirle el número de discos nuevos deseados
cmdNuevosDiscos = "/usr/bin/VBoxManage storagectl {} --name {} --portcount {}".\
    format(maquinaTrabajo,tipoControladora,numDiscos)
# print(cmdNuevosDiscos)
call(cmdNuevosDiscos, shell=True)
#Creamos los discos
for n in range(1,numDiscos+1):
    #Generamos nombre del disco del modo: $directorioMaquina\HD1-250GB.vdi
    nombreDisco = "{}HD{}-{}GiB.vdi".format(directorioMaquina,n,str(tamDiscos))
    # print(nombreDisco)
    #Agregamos disco
    cmdNuevoDisco = "/usr/bin/VBoxManage createmedium disk --filename \'{}\' --size {} -format VDI".\
        format(nombreDisco,tamDiscosMiB)
    # print(cmdNuevoDisco)
    call(cmdNuevoDisco, shell=True)
    #Conectamos disco a la controladora
    cmdConectarDisco = "/usr/bin/VBoxManage storageattach {} --storagectl {} --port {} --device 0 --type hdd --medium \'{}\'".\
        format(maquinaTrabajo,tipoControladora,n,nombreDisco)
    # print(cmdConectarDisco)
    call(cmdConectarDisco, shell=True)

