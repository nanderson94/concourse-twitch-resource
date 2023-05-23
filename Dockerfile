ARG base_image=alpine:latest

FROM ${base_image} AS resource

RUN apk update & apk upgrade
RUN apk --no-cache add \
    bash \
    curl \
    jq

ADD assets /opt/resource
RUN chmod +x /opt/resource/*

FROM resource AS builder
ARG twitchdl_version=1.1.19
WORKDIR /root

# It's a build layer, no need to squish
RUN apk --no-cache add go
RUN curl -L -o twitch-cli.tar.gz https://github.com/twitchdev/twitch-cli/archive/refs/tags/v${twitchdl_version}.tar.gz
RUN gunzip twitch-cli.tar.gz
RUN tar -x -f twitch-cli.tar
WORKDIR /root/twitch-cli-${twitchdl_version}
RUN go build --ldflags "-s -w -X main.buildVersion=source"
RUN mv twitch-cli /usr/local/bin/twitch

FROM resource AS tests
ADD test/ /tests
RUN /tests/all.sh

FROM resource
COPY --from=builder /usr/local/bin/twitch /usr/local/bin/twitch
