FROM alpine

LABEL maintainer="Yonier Gómez"

RUN apk add --update \
    samba-common-tools \
    samba-client \
    samba-server \
    && rm -rf /var/cache/apk/* \
    && addgroup sambita

ENV user=neytor \
    password=neytor \
    mygroup=sambita \
    mydir=/download \
    additional_dirs=""

COPY run.sh /opt/
RUN chmod +x /opt/run.sh

EXPOSE 139 445

ENTRYPOINT ["/bin/sh", "/opt/run.sh"]