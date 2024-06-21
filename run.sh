#!/bin/bash

# Imprimir todas las variables de entorno para depuración
echo "Environment variables:"
env

mygroup=$mygroup

# Función para crear directorios basados en variables de entorno
create_directory() {
    local dir_path="$1"
    local dir_name=$(basename "$dir_path")

    if [ -n "$dir_path" ]; then
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

# Procesar directorios predefinidos
create_directory "$mydir"

# Procesar directorios adicionales
IFS=',' read -ra DIRS <<< "$ADDITIONAL_DIRS"
for dir in "${DIRS[@]}"; do
    create_directory "$dir"
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