FROM golang:1.10-alpine as builder

RUN apk update
RUN apk add --no-cache git make glide

# install lnd with http pathes
RUN git clone https://github.com/LightningPeach/lnd.git /go/src/github.com/lightningnetwork/lnd
WORKDIR /go/src/github.com/lightningnetwork/lnd
RUN git checkout wallet
RUN make
RUN make install

# build gencert
RUN git clone https://github.com/btcsuite/btcd /go/src/github.com/btcsuite/btcd

WORKDIR /go/src/github.com/btcsuite/btcd

RUN glide install
RUN go install ./cmd/gencerts

# Start a new, final image to reduce size.
FROM alpine as final

# Expose lnd ports (server, rpc, rest).
EXPOSE 9735 10009 8080

# Copy the binaries and entrypoint from the builder image.
COPY --from=builder /go/bin/lncli /bin/
COPY --from=builder /go/bin/lnd /bin/
COPY --from=builder /go/bin/gencerts /bin/

# Add bash.
RUN apk add --no-cache \
    bash

# Copy the entrypoint script.
COPY ./start-lnd.sh .
COPY ./lncli.sh .
RUN chmod +x start-lnd.sh lncli.sh

CMD ["./start-lnd.sh"]
