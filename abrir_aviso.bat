@echo off
:: Abrir el aviso.html en el navegador predeterminado del usuario

:: Ruta del archivo en Netlogon
set AVISO=\\dnsserver\Compartir$\avisos\aviso.html

:: Abrir con el navegador predeterminado
start "" "%AVISO%"

exit
