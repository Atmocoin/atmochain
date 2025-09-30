
# syntax=docker/dockerfile:1
FROM golang:1.23.3 AS build

ARG SDK_TAG=v0.53.4
ENV CGO_ENABLED=1
# гарантуємо правильний тулчейн Go 1.23.x для SDK
ENV GOTOOLCHAIN=go1.23.3+auto

RUN apt-get update && apt-get install -y --no-install-recommends git ca-certificates make gcc g++ && rm -rf /var/lib/apt/lists/*

WORKDIR /src
RUN git clone --depth 1 --branch ${SDK_TAG} https://github.com/cosmos/cosmos-sdk.git
WORKDIR /src/cosmos-sdk

# Build simd (reference app) as our node binary
RUN make build
RUN install -Dm755 build/simd /usr/local/bin/atmod

# ---------- Runtime image ----------
FROM debian:bookworm-slim

ENV ATMO_HOME=/home/atmo/.atmo_home
ENV CHAIN_ID=atmochain-1
ENV MONIKER=atmo-validator
ENV MIN_GAS_PRICE="0.005uatmo"

RUN useradd -m atmo && mkdir -p ${ATMO_HOME} && chown -R atmo:atmo /home/atmo

COPY --from=build /usr/local/bin/atmod /usr/local/bin/atmod
COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

USER atmo
WORKDIR /home/atmo

EXPOSE 26656 26657 1317 9090

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
