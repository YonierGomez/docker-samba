#!/bin/bash

# Imprimir todas las variables de entorno
echo "Environment variables:"
env

mygroup=$mygroup

# Función para crear directorios basados en variables de entorno
create_directory() {
    local var_prefix="$1"
    local dir_path="${!var_prefix}"
    local dir_name=$(basename "$dir_path")

    if [ -n "$dir_path" ]; then
        # Create the directory
        echo ================================================
        echo Creating directory $dir_path
        echo ================================================
        mkdir -p "$dir_path"
        chgrp -R $mygroup "$dir_path"  # Asignar el grupo recursivamente
        chmod 770 "$dir_path"

        # Add a Samba share configuration
        echo ================================================
        echo Adding Samba share for $dir_name
        echo ================================================
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
    fi
}

# Crear directorios para todas las variables de entorno que empiecen con "mydir"
for var in $(env | grep '^mydir'); do
    create_directory "$var"
done

# Crear directorios para mydirdos
create_directory "mydirdos"

# Crear directorios para mydircuatro (si se ha pasado como variable de entorno)
create_directory "mydircuatro"

# Validar configuración de Samba
echo ================================================
echo Validating Samba configuration
echo ================================================
testparm -s

# Mostrar credenciales de usuario
echo ================================================
echo Estas son tus credenciales
echo ================================================
echo "Usuario: $user"
echo "Contraseña: $password"

# Iniciar el servidor Samba
echo ================================================
echo Accede a través de smb://myIp
echo ================================================
echo Iniciando el servidor Samba
smbd --foreground --debug-stdout --no-process-group
