FROM --platform=linux/amd64 alpine

WORKDIR /app

RUN wget https://github.com/cerc-io/go-ethereum/releases/download/v1.10.23-statediff-4.2.0-alpha/geth-linux-amd64 && \
	mv geth-linux-amd64 geth && \
	chmod +x geth && \
	mv geth /usr/local/bin

# copy all files
ADD . .

CMD ["./run.sh"]
