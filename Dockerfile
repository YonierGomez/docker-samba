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
    additional_dirs=/mydirdos,/books,/mydirtres

COPY run.sh /opt/
ENTRYPOINT [ "sh", "/opt/run.sh" ] 
