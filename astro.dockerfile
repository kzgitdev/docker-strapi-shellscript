# syntax=docker/dockerfile:1
FROM node:22.10.0-alpine3.20

RUN apk upgrade --update-cache && \
    apk add openssl bash shadow && \
    rm -rf /var/cache/apk/*

WORKDIR /src

RUN groupmod -g 1002 node && \
    usermod -u 1002 node && \
    chown -R node:node /src

USER node