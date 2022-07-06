FROM --platform=linux/amd64 alpine

WORKDIR /app

RUN wget https://github.com/vulcanize/go-ethereum/releases/download/v1.10.19-statediff-4.0.4-alpha/geth-linux-amd64 && \
	mv geth-linux-amd64 geth && \
	chmod +x geth && \
	mv geth /usr/local/bin

# copy all files
ADD . .

CMD ["./run.sh"]
