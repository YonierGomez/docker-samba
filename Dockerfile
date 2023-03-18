FROM alpine

RUN apk add --update \
    samba-common-tools \
    samba-client \
    samba-server \
    && rm -rf /var/cache/apk/*

ENV user=neytor \
    password=neytor \
    mygroup=sambita \
    dir=/download

COPY run.sh /opt/
ENTRYPOINT [ "sh", "/opt/run.sh" ] 