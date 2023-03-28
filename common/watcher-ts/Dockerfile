FROM node:18.15.0-alpine3.16

RUN apk --update --no-cache add python3 alpine-sdk

RUN echo "git clone https://github.com/cerc-io/watcher-ts.git" && \
    git clone https://github.com/cerc-io/watcher-ts.git /app && \
    cd app && git checkout v0.2.33 && \
    yarn && yarn build

WORKDIR /app/packages/mobymask-watcher
