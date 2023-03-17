#!/bin/bash

user=neytor
password=neytor
grupo=sambita
dir=/opt/download
#DEFINIR USUARIO
echo ================================================
echo Creando usuario $user y directorio
echo ================================================
adduser -D $user
passwd -d $password
addgroup -g 8888 $grupo
# usermod -G $grupo $user
addgroup -S neytor sambita
mkdir $dir
chgrp $grupo $dir
chmod 770 $dir

echo ================================================
echo Configurando archivo samba
echo ================================================

echo "Hola $(hostname -f file example)" > $dir/file.txt
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
map to guest = bad user
dns proxy = no
ntlm auth = true
server multi channel support = yes
bind interfaces only = yes
hosts allow = 192., 127., ::1, 172.
hosts deny = 0.0.0.0/0
guest account = nobody
pam password change = yes
map to guest = bad user
usershare allow guests = yes
create mask = 0664
force create mode = 0664
directory mask = 0775
force directory mode = 0775
socket options = TCP_NODELAY
strict locking = no
local master = no
winbind scan trusted domains = yes
vfs objects = fruit streams_xattr
fruit:metadata = stream
fruit:model = MacSamba
fruit:posix_rename = yes
fruit:veto_appledouble = no
fruit:wipe_intentionally_left_blank_rfork = yes
fruit:delete_empty_adfiles = yes
fruit:time machine = yes

[download]
comment = Descargas
path = $dir
browsable = yes
writable = yes
valid users = @$grupo
write list = @$grupo
force group = +$grupo
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
echo Ingresa via smb://localhost$dir
echo ================================================

echo ================================================
echo Subiendo el server samba
echo ================================================
smbd --foreground --debug-stdout --no-process-group
