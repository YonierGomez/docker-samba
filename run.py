import os
import subprocess

def create_smb_conf():
    smb_conf = """
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

    # TCP/IP optimizations
    socket options = TCP_NODELAY SO_RCVBUF=131072 SO_SNDBUF=131072

    # Performance parameters
    read raw = yes
    write raw = yes
    getwd cache = yes

    # APPLE
    vfs objects = streams_xattr
    fruit:metadata = stream
    fruit:model = MacSamba
    fruit:posix_rename = yes
    fruit:veto_appledouble = no
    fruit:wipe_intentionally_left_blank_rfork = yes
    fruit:delete_empty_adfiles = yes
    fruit:time machine = yes
    """
    with open('/etc/samba/smb.conf', 'w') as f:
        f.write(smb_conf)

def add_smb_share(dir_name, dir_path, mygroup):
    share_conf = f"""
    [{dir_name}]
    comment = {dir_name}
    path = {dir_path}
    browsable = yes
    writable = yes
    valid users = @{mygroup}
    write list = @{mygroup}
    force group = +{mygroup}
    create mask = 0770
    guest ok = no
    """
    with open('/etc/samba/smb.conf', 'a') as f:
        f.write(share_conf)

def create_user(user, password, mygroup):
    if subprocess.call(['id', '-u', user], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL) != 0:
        print("===============================================")
        print(f"Creating user {user}")
        print("===============================================")
        subprocess.run(['adduser', '-D', user])
        subprocess.run(['sh', '-c', f'echo -e "{password}\n{password}" | smbpasswd -a -s {user}'])
        subprocess.run(['addgroup', '-g', '8888', mygroup])
        subprocess.run(['addgroup', '-S', user, mygroup])

def create_dir_and_share(dir_path, mygroup):
    dir_name = os.path.basename(dir_path)
    print("===============================================")
    print(f"Creating directory {dir_path}")
    print("===============================================")
    os.makedirs(dir_path, exist_ok=True)
    subprocess.run(['chgrp', '-R', mygroup, dir_path])
    subprocess.run(['chmod', '770', dir_path])

    print("===============================================")
    print(f"Adding Samba share for {dir_name}")
    print("===============================================")
    add_smb_share(dir_name, dir_path, mygroup)

def main():
    user = os.getenv('user')
    password = os.getenv('password')
    mygroup = os.getenv('mygroup')
    additional_dirs = os.getenv('additional_dirs', '')

    create_smb_conf()
    create_user(user, password, mygroup)

    # Create directories from environment variables starting with "mydir"
    for key, value in os.environ.items():
        if key.startswith('mydir'):
            create_dir_and_share(value, mygroup)

    # Create additional directories specified in additional_dirs
    if additional_dirs:
        for dir_path in additional_dirs.split(','):
            create_dir_and_share(dir_path, mygroup)

    # print("===============================================")
    # print("Validating Samba configuration")
    # print("===============================================")
    # subprocess.run(['testparm', '-s'])

    print("===============================================")
    print("These are your credentials")
    print("===============================================")
    print(f"User: {user}")
    print(f"Password: {password}")

    print("===============================================")
    print("Access via smb://myIp")
    print("===============================================")
    print("Starting the Samba server")
    subprocess.run(['smbd', '--foreground', '--debug-stdout', '--no-process-group'])

if __name__ == "__main__":
    main()
