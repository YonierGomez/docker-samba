# Docker Samba - Servidor de archivos compartidos

Comparte archivos entre Windows, Linux y macOS con Samba en Docker. Imagen multi-arquitectura lista para x86, ARM64 y Raspberry Pi.

![Samba](https://upload.wikimedia.org/wikipedia/commons/thumb/d/db/Samba_logo_2010.svg/2880px-Samba_logo_2010.svg.png)

## Inicio rápido

```bash
docker run -d --name samba \
  -p 445:445 -p 137:137/udp -p 138:138/udp -p 139:139/tcp \
  -v samba:/download \
  neytor/samba
```

Accede desde cualquier equipo: `smb://tu-ip`
- Usuario: `neytor`
- Contraseña: `neytor`

## Arquitecturas soportadas

La imagen es **multi-arch**. Docker detecta tu arquitectura automáticamente y descarga la versión correcta.

| Arquitectura | Dispositivos típicos | Comando |
|---|---|---|
| x86-64 (amd64) | PCs, servidores, VMs | `docker pull neytor/samba` |
| ARM64 (aarch64) | Raspberry Pi 3/4/5, Apple Silicon | `docker pull neytor/samba` |
| ARMv7 (armhf) | Raspberry Pi 2, dispositivos IoT | `docker pull neytor/samba` |

> Ya no necesitás usar el tag `:arm`. El mismo `neytor/samba` funciona en todas las plataformas.

### Forzar una arquitectura específica

Si necesitás descargar una arquitectura diferente a la de tu máquina (ej: para pruebas):

```bash
# Forzar ARM64
docker pull --platform linux/arm64 neytor/samba

# Forzar x86-64
docker pull --platform linux/amd64 neytor/samba

# Forzar ARMv7
docker pull --platform linux/arm/v7 neytor/samba
```

## Instalación

### Docker Compose (recomendado)

```yaml
services:
  samba:
    image: neytor/samba
    container_name: samba_server
    restart: always
    environment:
      - user=neytor
      - password=neytor
      - mygroup=sambita
      - mydir=/download
      - additional_dirs=/media,/backups
    ports:
      - 445:445
      - 137:137/udp
      - 138:138/udp
      - 139:139/tcp
    volumes:
      - samba:/download
      - /ruta/local/media:/media
      - /ruta/local/backups:/backups

volumes:
  samba:
```

### Docker CLI

```bash
docker run -d --name samba_server \
  -v samba:/download \
  -e user=neytor \
  -e password=neytor \
  -e mydir=/download \
  -e additional_dirs=/work,/media \
  -e mygroup=sambita \
  -p 445:445 -p 137:137/udp -p 138:138/udp -p 139:139/tcp \
  neytor/samba
```

## Variables de entorno

| Variable | Descripción | Valor por defecto |
|---|---|---|
| `user` | Usuario para autenticación SMB | `neytor` |
| `password` | Contraseña del usuario | `neytor` |
| `mygroup` | Grupo de Samba (GID 8888) | `sambita` |
| `mydir` | Directorio compartido principal | `/download` |
| `additional_dirs` | Directorios extra separados por coma | _(vacío)_ |

> Se recomienda pasar `password` mediante Docker secrets o un archivo `.env` en producción.

## Rendimiento

Para mejor velocidad, usá la red `host`:

```bash
docker run -d --name samba_server \
  --network host \
  -v samba:/download \
  neytor/samba
```

## Uso en Raspberry Pi

Funciona en cualquier Raspberry Pi sin configuración extra:

```bash
docker run -d --name samba_server \
  -v samba:/download \
  -p 445:445 -p 137:137/udp -p 138:138/udp -p 139:139/tcp \
  neytor/samba
```

> La imagen detecta automáticamente si tu Pi es ARM64 o ARMv7.

## Releases automáticos

Este proyecto verifica semanalmente si hay nuevas versiones de Samba en Alpine Linux. Cuando se detecta una actualización, se genera automáticamente:
- Build multi-arch (amd64, arm64, armv7)
- Push a Docker Hub con tags `latest` y versión específica
- GitHub Release con notas de la versión

## Links

- [Docker Hub](https://hub.docker.com/r/neytor/samba)
- [GitHub](https://github.com/YonierGomez/docker-samba)
- [Web del autor](https://www.yonier.com)
