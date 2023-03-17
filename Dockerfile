FROM alpine

RUN apk add --update \
    samba-common-tools \
    samba-client \
    samba-server \
    && rm -rf /var/cache/apk/*

COPY run.sh /opt/
CMD sh /opt/run.sh
