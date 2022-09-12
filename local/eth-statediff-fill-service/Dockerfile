FROM golang:1.18-alpine as builder

RUN apk --update --no-cache add make git g++ linux-headers
# DEBUG
RUN apk add busybox-extras

# Build eth-statediff-fill-service
WORKDIR /app

RUN git clone https://github.com/vulcanize/eth-statediff-fill-service.git && \
	cd eth-statediff-fill-service && git checkout v4.0.5-alpha && \
	go mod download

# Build the binary
RUN cd eth-statediff-fill-service && \
	GCO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -ldflags '-extldflags "-static"' -o eth-statediff-fill-service .

RUN chmod +x ./eth-statediff-fill-service/eth-statediff-fill-service && mv ./eth-statediff-fill-service/eth-statediff-fill-service /usr/local/bin

# copy all files
ADD . .

CMD ["./run.sh"]
