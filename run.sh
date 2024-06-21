#!/bin/bash
env
# Mover el archivo smb.conf original a smb.backup
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
    echo "================================================"
    echo "Creating user $user"
    echo "================================================"
    adduser -D $user
    echo -e "$password\n$password" | smbpasswd -a -s $user
    addgroup -g 8888 $mygroup
    addgroup -S $user $mygroup
fi

# Función para crear directorio y agregar recurso compartido de Samba
create_samba_share() {
    local dir_path=$1
    if [ -z "$dir_path" ]; then
        echo "Directory path is empty, skipping..."
        return
    fi
    local dir_name=$(basename "$dir_path")

    echo "================================================"
    echo "Creating directory $dir_path"
    echo "================================================"
    mkdir -p "$dir_path"
    chgrp -R $mygroup "$dir_path"
    chmod 770 "$dir_path"

    echo "================================================"
    echo "Adding Samba share for $dir_name"
    echo "================================================"
    {
        echo "[$dir_name]"
        echo "comment = $dir_name"
        echo "path = $dir_path"
        echo "browsable = yes"
        echo "writable = yes"
        echo "valid users = @$mygroup"
        echo "write list = @$mygroup"
        echo "force group = +$mygroup"
        echo "create mask = 0770"
        echo "guest ok = no"
    } >> /etc/samba/smb.conf
}

# Crear el directorio principal y recurso compartido si mydir no está vacío
if [ -n "$mydir" ]; then
    create_samba_share "$mydir"
else
    echo "mydir is empty, skipping..."
fi

# Procesar additional_dirs si no está vacío
if [ -n "$additional_dirs" ]; then
    IFS=',' read -ra ADDR <<< "$additional_dirs"
    for dir_path in "${ADDR[@]}"; do
        create_samba_share "$dir_path"
    done
else
    echo "additional_dirs is empty, skipping..."
fi

# Validar la configuración de Samba
echo "================================================"
echo "Validating Samba configuration"
echo "================================================"
testparm -s

# Mostrar credenciales de usuario
echo "================================================"
echo "These are your credentials"
echo "================================================"
echo "User: $user"
echo "Password: $password"

# Iniciar el servidor Samba
echo "================================================"
echo "Access via smb://myIp"
echo "================================================"
echo "Starting the Samba server"
smbd --foreground --debug-stdout --no-process-group