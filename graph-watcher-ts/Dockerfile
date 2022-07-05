FROM node:16.15.1-alpine3.16

ARG GIT_TOKEN

RUN echo $GIT_TOKEN

RUN apk --update --no-cache add python3 alpine-sdk && \
    git config --global credential.helper \
    '!f() { echo username=author; echo "password=$GIT_TOKEN"; };f'

RUN echo //npm.pkg.github.com/:_authToken=$GIT_TOKEN > ~/.npmrc

RUN echo "git clone https://github.com/vulcanize/graph-watcher-ts.git" && \
    git clone https://github.com/vulcanize/graph-watcher-ts.git /app && \
    cd app && git checkout v0.2.1 && \
    yarn && yarn build

WORKDIR /app/packages/moby-mask-watcher
