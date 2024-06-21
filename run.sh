#!/bin/bash

# Imprimir todas las variables de entorno para depuración
echo "Environment variables:"
env

mygroup=$mygroup

# Función para crear directorios basados en variables de entorno
create_directory() {
    local var_prefix="$1"
    local dir_path="${!var_prefix}"  # Acceder al valor de la variable usando ${!var}

    if [ -n "$dir_path" ]; then
        local dir_name=$(basename "$dir_path")

        # Crear el directorio
        echo ================================================
        echo Creando directorio $dir_path
        echo ================================================
        mkdir -p "$dir_path"
        chgrp -R $mygroup "$dir_path"  # Asignar el grupo recursivamente
        chmod 770 "$dir_path"

        # Agregar configuración de Samba
        echo ================================================
        echo Agregando recurso compartido Samba para $dir_name
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

# Validar configuración de Samba
echo ================================================
echo Validando configuración de Samba
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
echo Accede a través de smb://miIP
echo ================================================
echo Iniciando el servidor Samba
smbd --foreground --debug-stdout --no-process-group
