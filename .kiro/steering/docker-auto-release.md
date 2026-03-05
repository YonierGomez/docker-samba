---
inclusion: manual
---

# Guía: CI/CD Docker Multi-Arch con Auto-Release

Instrucciones para configurar un pipeline de GitHub Actions que:
- Hace build multi-arquitectura (amd64, arm64, armv7) usando QEMU + Buildx
- Detecta automáticamente nuevas versiones del paquete principal
- Genera releases con changelog del upstream
- Funciona con el plan gratuito de GitHub (sin runners ARM ni self-hosted)

## Requisitos previos

1. Secrets en el repo de GitHub:
   - `USER_HUB`: usuario de Docker Hub
   - `PASS_HUB`: token/contraseña de Docker Hub

2. Permisos del repo:
   - Settings → Actions → General → Workflow permissions → "Read and write permissions"

## Estructura del workflow

El workflow tiene estas fases:

### 1. Detección de versión
- Ejecuta un container de la imagen base (ej: Alpine) y consulta la versión del paquete principal
- Compara con el último release del repo en GitHub
- Si son iguales, no hace nada

### 2. Build multi-arch
- Usa QEMU para emular ARM desde x86
- Usa Docker Buildx para compilar en paralelo para todas las plataformas
- Push a Docker Hub con tags `latest` y versión específica

### 3. Release con changelog
- Consulta las release notes del proyecto upstream
- Crea un GitHub Release con:
  - Changelog/novedades del upstream
  - Tags de Docker disponibles
  - Tabla de arquitecturas soportadas
  - Instrucciones de uso rápido

## Cómo adaptar a otro proyecto

Para adaptar este pipeline a otro repo Docker, necesito saber:

1. **Imagen base del Dockerfile** (ej: alpine, ubuntu, debian)
2. **Paquete principal** que determina la versión (ej: samba, nginx, redis)
3. **Nombre de la imagen en Docker Hub** (ej: usuario/imagen)
4. **Dónde publica el upstream sus release notes** (URL del changelog)
5. **Frecuencia de verificación** (semanal, diaria, etc.)

Con esa info, adapto:
- El comando para consultar la versión del paquete
- El parsing de las release notes del upstream
- Los tags de Docker Hub
- El cron del schedule

## Referencia: workflow de docker-samba

El archivo `.github/workflows/docker-image.yml` de este repo es la implementación de referencia.
Usa `apk list` para Alpine y consulta `samba.org/samba/history/` para el changelog.
