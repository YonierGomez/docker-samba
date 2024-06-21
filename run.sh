#!/bin/bash

mygroup=$mygroup

# Move the original smb.conf to smb.backup
mv /etc/samba/smb.conf /etc/samba/smb.backup

# Create a new smb.conf with the global configuration
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

# Create the user if it doesn't exist
if ! id -u $user &>/dev/null; then
    echo ================================================
    echo Creating user $user
    echo ================================================
    adduser -D $user
    echo -e "$password\n$password" | smbpasswd -a -s $user
    addgroup -g 8888 $mygroup
    addgroup -S $user $mygroup
fi

# Process additional_dirs variable
IFS=',' read -ra ADDR <<< "$additional_dirs"
for dir_path in "${ADDR[@]}"; do
    dir_name=$(basename "$dir_path")

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
done

# Validate Samba configuration
echo ================================================
echo Validating Samba configuration
echo ================================================
testparm -s

# Display user credentials
echo ================================================
echo These are your credentials
echo ================================================
echo "User: $user"
echo "Password: $password"

# Start the Samba server
echo ================================================
echo Access via smb://myIp
echo ================================================
echo Starting the Samba server
smbd --foreground --debug-stdout --no-process-group
