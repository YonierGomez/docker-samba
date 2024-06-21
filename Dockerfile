FROM alpine
LABEL maintainer <Yonier Gómez>
RUN apk add --update \
    samba-common-tools \
    samba-client \
    samba-server \
    && rm -rf /var/cache/apk/*
ENV user=neytor \
    password=neytor \
    mygroup=sambita \
    mydir=/download \
    mydirdos=/work
COPY run.sh /run.sh
RUN chmod +x /run.sh  # Asegurar que el script tiene permisos de ejecución
ENTRYPOINT [ "sh", "-c", "/run.sh" ]