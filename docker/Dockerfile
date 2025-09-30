# syntax=docker/dockerfile:1.7-labs
FROM golang:1.23.3 AS build
ARG SDK_TAG=v0.53.4
ENV CGO_ENABLED=1
ENV GOTOOLCHAIN=go1.23.3+auto
RUN apt-get update && apt-get install -y --no-install-recommends git ca-certificates make gcc g++ curl jq && rm -rf /var/lib/apt/lists/*
WORKDIR /src
# Fetch the exact tag without re-cloning on every build layer (better cacheability)
RUN git init cosmos-sdk && cd cosmos-sdk \
    && git remote add origin https://github.com/cosmos/cosmos-sdk.git \
    && git fetch --depth=1 origin ${SDK_TAG} \
    && git checkout FETCH_HEAD
WORKDIR /src/cosmos-sdk
# Use BuildKit caches for modules and build cache
RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    make build

RUN install -Dm755 build/simd /usr/local/bin/atmod

FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates curl jq bash sed grep && rm -rf /var/lib/apt/lists/*
ENV ATMO_HOME=/home/atmo/.atmo_home
ENV CHAIN_ID=atmochain-1
ENV MONIKER=atmo-node
ENV MIN_GAS_PRICE="0.005uatmo"
ENV JOIN_MODE=peer
ENV GENESIS_URL=
ENV PERSISTENT_PEERS=
ENV EXTERNAL_ADDRESS=
RUN useradd -m atmo && mkdir -p ${ATMO_HOME} && chown -R atmo:atmo /home/atmo
COPY --from=build /usr/local/bin/atmod /usr/local/bin/atmod
COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
USER atmo
WORKDIR /home/atmo
EXPOSE 26656 26657 1317 9090
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
