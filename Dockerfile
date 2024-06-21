FROM alpine

LABEL maintainer <Yonier Gómez>

RUN apk add --update \
    samba-common-tools \
    samba-client \
    samba-server \
    python3 \
    py3-pip \
    && rm -rf /var/cache/apk/*

ENV user=neytor \
    password=neytor \
    mygroup=sambita \
    mydir=/download \
    additional_dirs=""

COPY run.py /opt/
ENTRYPOINT [ "python3", "/opt/run.py" ]