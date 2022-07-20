FROM node:16.15.1-alpine3.16

RUN apk --update --no-cache add python3 alpine-sdk

RUN echo "git clone https://github.com/vulcanize/MobyMask.git" && \
    git clone https://github.com/vulcanize/MobyMask.git /app && \
    cd app && git checkout v0.1.1 && \
    yarn

RUN sed -i 's/localhost:8545/geth:8545/' /app/packages/hardhat/hardhat.config.js

WORKDIR /app
