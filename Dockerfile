ARG base_image=alpine:latest
ARG twitchdl_version=v1.1.19

FROM ${base_image} AS resource

RUN apk update & apk upgrade
RUN apk --no-cache add \
    bash \
    curl \
    jq

ADD assets /opt/resource
RUN chmod +x /opt/resource/*

FROM resource AS builder
WORKDIR /root
RUN apk --no-cache add go \
    && curl -L -o twitch-cli.tar.gz https://github.com/twitchdev/twitch-cli/archive/refs/tags/${twitchdl_version}.tar.gz \
    && tar -x -f twitch-cli.tar.gz
WORKDIR /root/twitch-cli
RUN go build --ldflags "-s -w -X main.buildVersion=source"

FROM resource AS tests
ADD test/ /tests
RUN /tests/all.sh

FROM resource
COPY --from builder /root/twitch-cli/build/twitch /usr/local/bin/twitch