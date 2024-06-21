FROM alpine

LABEL maintainer="Yonier Gómez"

# Instalar Samba y limpiar la caché de apk
RUN apk add --update \
    samba-common-tools \
    samba-client \
    samba-server \
    && rm -rf /var/cache/apk/*

# Configurar variables de entorno predeterminadas
ENV user=neytor \
    password=neytor \
    mygroup=sambita \
    mydir=/download \
    mydirdos=/work

# Copiar el script de ejecución
COPY run.sh /opt/run.sh

# Dar permisos de ejecución al script
RUN chmod +x /opt/run.sh

# Exponer los puertos necesarios para Samba
EXPOSE 139 445

# Configurar el punto de entrada para diagnóstico
ENTRYPOINT ["/bin/sh", "-c", "ls -l /opt && cat /opt/run.sh && /bin/sh /opt/run.sh"]