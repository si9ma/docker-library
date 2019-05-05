# for golang debug in docker
FROM golang:1.12-alpine

LABEL author="si9ma"
LABEL email="si9ma@si9ma.com"

RUN apk add \
            # bash for docker-entrypoint.sh
            bash \
            # for go get
            git  

ADD docker-entrypoint.sh /

ENV CGO_ENABLED=0
ENV GOOS=linux
ENV GOARCH=amd64

EXPOSE 2345

# install dlv
RUN go get -v -u github.com/derekparker/delve/cmd/dlv

ENTRYPOINT [ "/docker-entrypoint.sh" ]