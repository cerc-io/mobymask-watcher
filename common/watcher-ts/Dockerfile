FROM node:16.15.1-alpine3.16

RUN apk --update --no-cache add python3 alpine-sdk

RUN echo "git clone https://github.com/vulcanize/assemblyscript.git" && \
    git clone https://github.com/vulcanize/assemblyscript.git /assemblyscript && \
    cd assemblyscript && git checkout ng-integrate-asyncify && \
    npm install && npm run build && yarn link

RUN echo "git clone https://github.com/cerc-io/watcher-ts.git" && \
    git clone https://github.com/cerc-io/watcher-ts.git /app && \
    cd app && git checkout v0.2.12 && \
    cd packages/graph-node && yarn remove @vulcanize/assemblyscript && \
    yarn add https://github.com/vulcanize/assemblyscript.git#ng-integrate-asyncify && \
    cd /app && yarn && yarn link "@vulcanize/assemblyscript" && yarn build

WORKDIR /app/packages/mobymask-watcher
