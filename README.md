# Docker Samba - Servidor de archivos compartidos

[![Landing Page](https://img.shields.io/badge/🌐_Landing-Page-blue)](https://yoniergomez.github.io/docker-samba/)
[![Docker Hub](https://img.shields.io/docker/pulls/neytor/samba?logo=docker&label=Docker%20Pulls)](https://hub.docker.com/r/neytor/samba)
[![Docker Image Size](https://img.shields.io/docker/image-size/neytor/samba/latest?logo=docker&label=Image%20Size)](https://hub.docker.com/r/neytor/samba)
[![GitHub Release](https://img.shields.io/github/v/release/YonierGomez/docker-samba?logo=github&label=Release)](https://github.com/YonierGomez/docker-samba/releases)
[![GitHub Stars](https://img.shields.io/github/stars/YonierGomez/docker-samba?style=flat&logo=github&label=Stars)](https://github.com/YonierGomez/docker-samba/stargazers)
[![GitHub Forks](https://img.shields.io/github/forks/YonierGomez/docker-samba?style=flat&logo=github&label=Forks)](https://github.com/YonierGomez/docker-samba/network/members)
[![GitHub License](https://img.shields.io/github/license/YonierGomez/docker-samba?logo=opensourceinitiative&label=License)](https://github.com/YonierGomez/docker-samba/blob/main/LICENSE)
[![CI Status](https://img.shields.io/github/actions/workflow/status/YonierGomez/docker-samba/docker-image.yml?logo=githubactions&label=CI)](https://github.com/YonierGomez/docker-samba/actions)

### Tecnologías

![Docker](https://img.shields.io/badge/Docker-2496ED?logo=docker&logoColor=white)
![Alpine Linux](https://img.shields.io/badge/Alpine_Linux-0D597F?logo=alpinelinux&logoColor=white)
![Samba](https://img.shields.io/badge/Samba-SMB3-green)
![Python](https://img.shields.io/badge/Python-3776AB?logo=python&logoColor=white)
![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-2088FF?logo=githubactions&logoColor=white)
![ARM](https://img.shields.io/badge/ARM-0091BD?logo=arm&logoColor=white)
![x86-64](https://img.shields.io/badge/x86--64-blue)

Comparte archivos entre Windows, Linux y macOS con Samba en Docker. Imagen multi-arquitectura lista para x86, ARM64 y placas SBC (Raspberry Pi, Orange Pi, etc).

<p align="center">
  <img src="https://upload.wikimedia.org/wikipedia/commons/thumb/d/db/Samba_logo_2010.svg/800px-Samba_logo_2010.svg.png" alt="Samba" width="300">
</p>

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

| Arquitectura | Dispositivos compatibles | Comando |
|---|---|---|
| x86-64 (amd64) | PCs, servidores, VMs, NAS | `docker pull neytor/samba` |
| ARM64 (aarch64) | Raspberry Pi 3B/3B+/4/5, Orange Pi 5/5B, Banana Pi M5, Rock Pi 4, NVIDIA Jetson, Apple Silicon | `docker pull neytor/samba` |
| ARMv7 (armhf) | Raspberry Pi 2B, Orange Pi Zero/Lite/One, Banana Pi M2, dispositivos IoT | `docker pull neytor/samba` |

> Ya no necesitás usar el tag `:arm`. El mismo `neytor/samba` funciona en todas las plataformas. Cualquier placa con arquitectura ARM (arm64 o armv7) es compatible.

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

## Uso en placas ARM (Raspberry Pi, Orange Pi, etc.)

Funciona en cualquier placa ARM sin configuración extra:

```bash
docker run -d --name samba_server \
  -v samba:/download \
  -p 445:445 -p 137:137/udp -p 138:138/udp -p 139:139/tcp \
  neytor/samba
```

> La imagen detecta automáticamente si tu placa es ARM64 o ARMv7. Compatible con Raspberry Pi (2B, 3B, 3B+, 4, 5), Orange Pi (Zero, Lite, One, 5, 5B), Banana Pi, Rock Pi, NVIDIA Jetson y cualquier SBC con arquitectura ARM.

## Releases automáticos

Este proyecto verifica semanalmente si hay nuevas versiones de Samba en Alpine Linux. Cuando se detecta una actualización, se genera automáticamente:
- Build multi-arch (amd64, arm64, armv7)
- Push a Docker Hub con tags `latest` y versión específica
- GitHub Release con changelog de Samba upstream

## Contribuir

Este repo usa branch protection en `main`. Todos los cambios van via Pull Request.

1. Crea una rama desde `main`
2. Hacé tus cambios y commiteá
3. Pusheá la rama y abrí un Pull Request
4. Una vez mergeado, la rama remota se borra automáticamente

```bash
git checkout -b mi-feature
# hacé tus cambios
git add -A && git commit -m "feat: mi cambio"
git push origin mi-feature
# abrí el PR desde GitHub, una vez mergeado:
git checkout main && git pull
git branch -d mi-feature
```

## Apoya el proyecto

Si te resulta útil, considerá apoyar el desarrollo:

[![Buy Me A Coffee](https://img.shields.io/badge/Buy_Me_A_Coffee-FFDD00?logo=buymeacoffee&logoColor=black)](https://buymeacoffee.com/yoniergomez)
[![GitHub Sponsors](https://img.shields.io/badge/GitHub_Sponsors-EA4AAA?logo=githubsponsors&logoColor=white)](https://github.com/sponsors/YonierGomez)

## Links

- [Landing Page](https://yoniergomez.github.io/docker-samba/)
- [Docker Hub](https://hub.docker.com/r/neytor/samba)
- [GitHub](https://github.com/YonierGomez/docker-samba)
- [Releases](https://github.com/YonierGomez/docker-samba/releases)
- [Web del autor](https://www.yonier.com)
