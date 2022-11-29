FROM --platform=linux/amd64 alpine

WORKDIR /app

RUN wget https://git.vdb.to/api/packages/cerc-io/generic/go-ethereum/v1.10.26-statediff-4.2.2-alpha/geth-linux-amd64 && \
	mv geth-linux-amd64 geth && \
	chmod +x geth && \
	mv geth /usr/local/bin

# copy all files
ADD . .

RUN ./init.sh

CMD ["./run.sh"]
