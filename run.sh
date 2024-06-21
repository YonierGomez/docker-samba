#!/bin/bash

# Asignar las variables de entorno si están definidas
user=${user:-neytor}
password=${password:-neytor}
mygroup=${mygroup:-sambita}

# Mover el smb.conf original a un respaldo
mv /etc/samba/smb.conf /etc/samba/smb.backup

# Crear un nuevo smb.conf con la configuración global
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
EOF

# Crear el usuario si no existe
if ! id -u $user &>/dev/null; then
    echo "=============================================="
    echo "Creating user $user"
    echo "=============================================="
    adduser -D $user
    echo -e "$password\n$password" | smbpasswd -a -s $user
    addgroup -g 8888 $mygroup
    addgroup -S $user $mygroup
fi

# Crear directorios a partir de las variables de entorno que empiecen con "mydir"
for var in $(env | grep '^mydir'); do
    dir_path="${var#*=}"
    dir_name=$(basename "$dir_path")

    echo "=============================================="
    echo "Creating directory $dir_path"
    echo "=============================================="
    mkdir -p "$dir_path"
    chgrp -R $mygroup "$dir_path"  # Asignar el grupo recursivamente
    chmod 770 "$dir_path"

    echo "=============================================="
    echo "Adding Samba share for $dir_name"
    echo "=============================================="
    cat << EOF >> /etc/samba/smb.conf
[$dir_name]
comment = $dir_name
path = $dir_path
browsable = yes
writable = yes
valid users = @$mygroup
write list = @$mygroup
force group = +$mygroup
create mask = 0770
guest ok = no
EOF
done

# Validar la configuración de Samba
echo "=============================================="
echo "Validating Samba configuration"
echo "=============================================="
testparm -s

# Mostrar las credenciales del usuario
echo "=============================================="
echo "These are your credentials"
echo "=============================================="
echo "User: $user"
echo "Password: $password"

# Iniciar el servidor Samba
echo "=============================================="
echo "Access via smb://myIp"
echo "=============================================="
echo "Starting the Samba server"
smbd --foreground --debug-stdout --no-process-group