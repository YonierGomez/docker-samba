#!/bin/bash

user=$user
password=$password
mygroup=$mygroup
dir=$dir

#DEFINIR USUARIO
echo ================================================
echo Creando usuario $user y directorio
echo ================================================
adduser -D $user
passwd -d $password
addgroup -g 8888 $mygroup
addgroup -S $user $mygroup
mkdir $dir
chgrp $mygroup $dir
chmod 770 $dir

echo ================================================
echo Configurando archivo samba
echo ================================================

mv /etc/samba/smb.conf /etc/samba/smb.backup
cat << EOF > /etc/samba/smb.conf
[global]
workgroup = WORKGROUP
server string = %h server (Samba, Ubuntu)
security = user
server role = standalone server
passdb backend = smbpasswd
log file = /var/log/samba/log.%m
max log size = 1000
protocol = SMB3
panic action = /usr/share/samba/panic-action %d
idmap config * : backend = tdb
hosts allow = 192., 127., ::1, 172.
hosts deny = 0.0.0.0/0
#APPLE
vfs objects = fruit streams_xattr
fruit:metadata = stream
fruit:model = MacSamba
fruit:posix_rename = yes
fruit:veto_appledouble = no
fruit:wipe_intentionally_left_blank_rfork = yes
fruit:delete_empty_adfiles = yes
fruit:time machine = yes

[$dir]
comment = $dir
path = $dir
browsable = yes
writable = yes
valid users = @$mygroup
write list = @$mygroup
force group = +$mygroup
create mask = 0770
guest ok = no
EOF

echo ================================================
echo Validando configuracion de samba
echo ================================================

testparm -s

echo ================================================
echo Configurando credenciales samba
echo ================================================

smbpasswd -a $user<<EOF
$password
$password
EOF

echo ================================================
echo Estas son tus credenciales
echo ================================================
echo "Usuario: $user"
echo "Contraseña: $password"

echo ================================================
echo Ingresa via smb://myIp
echo ================================================

echo ================================================
echo Subiendo el server samba
echo ================================================
smbd --foreground --debug-stdout --no-process-group
