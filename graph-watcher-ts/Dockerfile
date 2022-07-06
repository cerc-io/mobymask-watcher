FROM node:16.15.1-alpine3.16

ARG GIT_TOKEN

RUN apk --update --no-cache add python3 alpine-sdk && \
    git config --global credential.helper \
    '!f() { echo username=author; echo "password=$GIT_TOKEN"; };f'

RUN echo "git clone https://github.com/vulcanize/assemblyscript.git" && \
    git clone https://github.com/vulcanize/assemblyscript.git /assemblyscript && \
    cd assemblyscript && git checkout ng-integrate-asyncify && \
    npm install && npm run build && yarn link

RUN echo "git clone https://github.com/vulcanize/graph-watcher-ts.git" && \
    git clone https://github.com/vulcanize/graph-watcher-ts.git /app && \
    cd app && git checkout v0.2.1 && \
    cd packages/graph-node && yarn remove @vulcanize/assemblyscript && \
    yarn add https://github.com/vulcanize/assemblyscript.git#ng-integrate-asyncify && \
    cd /app && yarn && yarn link "@vulcanize/assemblyscript" && yarn build

WORKDIR /app/packages/moby-mask-watcher
