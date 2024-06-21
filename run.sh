#!/bin/sh

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
        chgrp -R $mygroup "$dir_path" || echo "Warning: Could not change group"
        chmod 770 "$dir_path"

        # Agregar configuración de Samba
        echo ================================================
        echo Agregando recurso compartido Samba para $dir_name
        echo ================================================
        echo "[$dir_name]" >> /etc/samba/smb.conf
        echo "comment = $dir_name" >> /etc/samba/smb.conf
        echo "path = $dir_path" >> /etc/samba/smb.conf
        echo "browsable = yes" >> /etc/samba/smb.conf
        echo "writable = yes" >> /etc/samba/smb.conf
        echo "valid users = @$mygroup" >> /etc/samba/smb.conf
        echo "write list = @$mygroup" >> /etc/samba/smb.conf
        echo "force group = +$mygroup" >> /etc/samba/smb.conf
        echo "create mask = 0770" >> /etc/samba/smb.conf
        echo "guest ok = no" >> /etc/samba/smb.conf
        echo "" >> /etc/samba/smb.conf
    fi
}

# Procesar mydir (definido en el Dockerfile)
create_directory "$mydir"

# Procesar todos los directorios adicionales que empiezan con "mydir"
for var in $(env | cut -d= -f1 | grep '^mydir' | grep -v '^mydir$'); do
    dir_path=$(eval echo \$$var)
    create_directory "$dir_path"
done

# Procesar directorios adicionales
IFS=',' read -ra DIRS <<< "$additional_dirs"
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