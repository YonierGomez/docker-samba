Comparte archivos entre Windows, Linux, Mac, todo con Samba
======================

## Referencia rápida

-	¿Qué es  samba?
-	¿Cuál es nuestro uso?
-	¿Cómo usar esta imagen?
-	Login por defecto
-	Arquitectura soportada
-	Variables
-	Rendimiento optimizado
-	Te invito a visitar mi web

## ¿Qué es  samba?

### Definición Wikipedia

**Samba** es una implementación libre del [protocolo](https://es.wikipedia.org/wiki/Protocolo_(informática)) de archivos compartidos de [Microsoft Windows](https://es.wikipedia.org/wiki/Microsoft_Windows) (antiguamente llamado [SMB](https://es.wikipedia.org/wiki/Server_Message_Block), renombrado posteriormente a CIFS) para sistemas de tipo [UNIX](https://es.wikipedia.org/wiki/UNIX). De esta forma, es posible que computadoras con [GNU/Linux](https://es.wikipedia.org/wiki/GNU/Linux), [Mac OS X](https://es.wikipedia.org/wiki/Mac_OS_X) o [Unix](https://es.wikipedia.org/wiki/Unix) en general se vean como servidores o actúen como clientes en redes de Windows. Samba también permite validar usuarios haciendo de [Controlador Principal de Dominio](https://es.wikipedia.org/wiki/Controlador_de_dominio) (PDC), como miembro de dominio e incluso como un dominio [Active Directory](https://es.wikipedia.org/wiki/Active_Directory) para redes basadas en Windows; aparte de ser capaz de servir colas de impresión, directorios compartidos y autentificar con su propio archivo de usuarios.

> [Samba Wikipedia](https://es.wikipedia.org/wiki/Samba_(software))

![smb](https://upload.wikimedia.org/wikipedia/commons/thumb/d/db/Samba_logo_2010.svg/2880px-Samba_logo_2010.svg.png)



## ¿Cuál es nuestro uso?

Nuestro servidor samba nos permitirá compartir directorio entre sitemas tales como WIndows, Linux, MacOS.

![Polymart Downloads](https://img.shields.io/polymart/downloads/323)

## ¿Cómo usar esta imagen?

Puede hacer uso de docker cli o docker compost

### Login por defecto

Para acceder a su recurso compartido siga la sintaxis descrita en la tabla:

| URL acceso            | Usuario por defecto | Contraseña por defecto |
| --------------------- | ------------------- | ---------------------- |
| `smb://miDireccionIP` | `neytor`            | `neytor`               |

### docker-compose (recomendado)

```yaml
---
version: '3'
services:
  samba_server:
    image: neytor/samba
    container_name: samba_server
    restart: always
    environment:
    	- user=neytor #OPCIONAL
    	- password=neytor #OPCIONAL
    	- mygroup=sambita #OPCIONAL
    	- dir=/download #OPCIONAL
    ports:
      - 445:445
      - 137:137/udp
      - 138:138/udp
      - 139:139/tcp
    volumes:
      - samba:/download
  volumes:
    samba:
...
```

> Nota: Puedes reemplazar environment por env_file y pasarle un archivo .env como valor, recuerde que el archivo .env debe tener las variables deseadas.

### docker cli

```bash
$ docker container run \
    --name sambita -v samba:/download \
    -p 445:445 -p 137:137/udp -p 138:138/udp -p 139:139/tcp \
    -d neytor/samba
```

## Arquitectura soportada

La arquitectura soportada es la siguiente:

| Arquitectura | Disponible | Tag descarga                 |
| ------------ | ---------- | ---------------------------- |
| x86-64       | ✅          | docker pull neytor/samba     |
| arm64        | ✅          | docker pull neytor/samba:arm |

## Variables

Puedes pasar las siguientes variables al crear el contenedor

| Variable      | Función                                                      |
| ------------- | ------------------------------------------------------------ |
| `-e user`     | Define el usuario para login - por defecto es neutro         |
| `-e password` | Define la contraseña para el usuario - por defecto es neutro |
| `-e mygroup`  | Define el nombre del grupo - por defecto un PGID de 8888 y grupo Zambia |
| `-e dir`      | Define el directorio que desea compartir - por defecto es /download |

#### Ejemplo completo

```bash
$ docker container run \
    --name sambita -v samba:/download \
    -e user=neytor \
    -e dir=/download \
    -e mygroup=sambita \
    -p 445:445 -p 137:137/udp -p 138:138/udp -p 139:139/tcp \  
    -d neytor/samba
```

## Environment variables desde archivo (Docker secrets)

Se recomienda pasar la variable `password`a través de un archivo.

## Rendimiento optimizado

Si desea una mejor velocidad se recomienda utilizar la red `host`

[![Try in PWD](https://github.com/play-with-docker/stacks/raw/cff22438cb4195ace27f9b15784bbb497047afa7/assets/images/button.png)](http://play-with-docker.com?stack=https://raw.githubusercontent.com/docker-library/docs/db214ae34137ab29c7574f5fbe01bc4eaea6da7e/wordpress/stack.yml)

## Te invito a visitar mi web

Puedes ver nuevos eventos en [https://www.yonier.com/](https://www.yonier.com).
