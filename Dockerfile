FROM golang:1.10-alpine as builder

RUN apk update
RUN apk add --no-cache git make build-base

# install lnd with http pathes
RUN git clone https://github.com/LightningPeach/lnd.git /go/src/github.com/lightningnetwork/lnd
WORKDIR /go/src/github.com/lightningnetwork/lnd
RUN git checkout wallet-mainnet
RUN make
RUN make install

ENV CGO_ENABLED=1
ENV CC=gcc
RUN go get -u github.com/cloudflare/cfssl/cmd/cfssl
RUN go get -u github.com/cloudflare/cfssl/cmd/cfssljson

# Start a new, final image to reduce size.
FROM alpine as final

# Expose lnd ports (server, rpc, rest).
EXPOSE 9735 10009 8080

# Copy the binaries and entrypoint from the builder image.
COPY --from=builder /go/bin/lncli /bin/
COPY --from=builder /go/bin/lnd /bin/
COPY --from=builder /go/bin/cfssl /bin/
COPY --from=builder /go/bin/cfssljson /bin/

# Add bash.
RUN apk add --no-cache \
    bash

# Copy the entrypoint script.
COPY ./start-lnd.sh .
COPY ./lncli.sh .
COPY ./server.json .
COPY ./config.json .
RUN chmod +x start-lnd.sh lncli.sh

CMD ["./start-lnd.sh"]
