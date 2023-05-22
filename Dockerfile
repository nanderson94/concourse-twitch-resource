ARG base_image=alpine:latest

FROM ${base_image} AS resource

RUN apk update & apk upgrade
RUN apk --no-cache add \
    bash \
    curl

ADD assets /opt/resource
RUN chmod +x /opt/resource/*

FROM resource AS tests
ADD test/ /tests
RUN /tests/all.sh

FROM resource