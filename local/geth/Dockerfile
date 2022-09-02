FROM --platform=linux/amd64 alpine

WORKDIR /app

RUN wget https://github.com/vulcanize/go-ethereum/releases/download/v1.10.21-statediff-4.1.2-alpha/geth-linux-amd64 && \
	mv geth-linux-amd64 geth && \
	chmod +x geth && \
	mv geth /usr/local/bin

# copy all files
ADD . .

RUN ./init.sh

CMD ["./run.sh"]
