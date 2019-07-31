FROM openfalcon/makegcc-golang:1.10-alpine as builder
LABEL maintainer laiwei.ustc@gmail.com
USER root

ENV FALCON_DIR=/open-falcon PROJ_PATH=${GOPATH}/src/github.com/open-falcon/chat

RUN mkdir -p $FALCON_DIR && \
    mkdir -p $FALCON_DIR/wechat && \
    mkdir -p $FALCON_DIR/wechat/var && \
    mkdir -p $PROJ_PATH && \
    apk add --no-cache ca-certificates bash git

COPY . ${PROJ_PATH}
WORKDIR ${PROJ_PATH}
RUN go get .../ && \
    ./control build  && \
    cp -f falcon-wechat $FALCON_DIR/wechat/ && \
    cp -f cmdocker/wechat.tpl $FALCON_DIR/wechat/ && \
    cp -f cmdocker/falcon-entry.sh $FALCON_DIR/ && \
    cp -f cmdocker/localtime.shanghai $FALCON_DIR/ && \
    rm -rf ${PROJ_PATH}

WORKDIR $FALCON_DIR
RUN tar -czf falcon-wechat.tar.gz ./


FROM alpine:3.7 as prog
USER root

ENV FALCON_DIR=/open-falcon FALCON_MODULE=wechat

RUN mkdir -p $FALCON_DIR && \
    apk add --no-cache ca-certificates bash util-linux

WORKDIR $FALCON_DIR

COPY --from=0  $FALCON_DIR/falcon-wechat.tar.gz  $FALCON_DIR/
COPY --from=0  $FALCON_DIR/localtime.shanghai  $FALCON_DIR/
RUN tar -zxf falcon-wechat.tar.gz && \
    rm -rf falcon-wechat.tar.gz && \
    mv localtime.shanghai /etc/localtime

EXPOSE 3999

# create config-files by ENV
CMD ["./falcon-entry.sh"]

