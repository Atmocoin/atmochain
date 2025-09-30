#!/usr/bin/env bash
set -euo pipefail
CHAIN_ID="${CHAIN_ID:-atmochain-1}"
MONIKER="${MONIKER:-atmo-node}"
MIN_GAS_PRICE="${MIN_GAS_PRICE:-0.005uatmo}"
GENESIS_URL="${GENESIS_URL:-http://212.23.203.145:26657/genesis}"
PERSISTENT_PEERS="${PERSISTENT_PEERS:-cff19e7f4a09c7dbb5efff2ecca4e70b936a5f07@212.23.203.145:26656}"
EXTERNAL_ADDRESS="${EXTERNAL_ADDRESS:-}"
ATMO_HOME="${ATMO_HOME:-$HOME/.atmo_home}"
need(){ command -v "$1" >/dev/null 2>&1 || { echo "Please install $1"; exit 1; }; }
for t in curl git jq go; do need "$t"; done
workdir="${WORKDIR:-$HOME/atmo_build}"; mkdir -p "$workdir"; cd "$workdir"
if [ ! -d cosmos-sdk ]; then git clone --depth 1 --branch v0.53.4 https://github.com/cosmos/cosmos-sdk.git; fi
cd cosmos-sdk && make build
install -Dm755 build/simd "$HOME/.local/bin/atmod"
mkdir -p "$ATMO_HOME/config"
curl -fsSL "$GENESIS_URL" | jq -r '.result.genesis // .' > "$ATMO_HOME/config/genesis.json"
atmod init "$MONIKER" --chain-id "$CHAIN_ID" --home "$ATMO_HOME" >/dev/null 2>&1 || true
APP_TOML="$ATMO_HOME/config/app.toml"; CONFIG_TOML="$ATMO_HOME/config/config.toml"
[ -f "$APP_TOML" ] && sed -i "s/^minimum-gas-prices = .*/minimum-gas-prices = \"$MIN_GAS_PRICE\"/g" "$APP_TOML" || true
[ -f "$CONFIG_TOML" ] && sed -i "s|^persistent_peers *=.*|persistent_peers = \"$PERSISTENT_PEERS\"|g" "$CONFIG_TOML" || true
[ -n "$EXTERNAL_ADDRESS" ] && sed -i "s|^external_address *=.*|external_address = \"$EXTERNAL_ADDRESS\"|g" "$CONFIG_TOML" || true
atmod genesis validate --home "$ATMO_HOME" || true
echo 'Start: ~/.local/bin/atmod start --home '"$ATMO_HOME"
