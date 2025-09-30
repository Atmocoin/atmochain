#!/usr/bin/env bash
set -euo pipefail
ATMO_HOME="${ATMO_HOME:-/home/atmo/.atmo_home}"
CHAIN_ID="${CHAIN_ID:-atmochain-1}"
MONIKER="${MONIKER:-atmo-node}"
MIN_GAS_PRICE="${MIN_GAS_PRICE:-0.005uatmo}"
JOIN_MODE="${JOIN_MODE:-peer}"
GENESIS_URL="${GENESIS_URL:-}"
PERSISTENT_PEERS="${PERSISTENT_PEERS:-}"
EXTERNAL_ADDRESS="${EXTERNAL_ADDRESS:-}"
if [ ! -f "${ATMO_HOME}/config/genesis.json" ]; then
  case "${JOIN_MODE}" in
    single)
      atmod init "${MONIKER}" --chain-id "${CHAIN_ID}" --home "${ATMO_HOME}"
      sed -i -E 's/"bond_denom": *"[^"]+"/"bond_denom":"uatmo"/' "${ATMO_HOME}/config/genesis.json"
      sed -i -E 's/"mint_denom": *"[^"]+"/"mint_denom":"uatmo"/'   "${ATMO_HOME}/config/genesis.json"
      sed -i -E 's/"constant_fee": *\{[^}]*"denom": *"[^"]+"/"constant_fee": {"denom":"uatmo"/' "${ATMO_HOME}/config/genesis.json"
      sed -i -E 's/"min_deposit": *\[[^]]*"denom": *"[^"]+"/"min_deposit": [{"denom":"uatmo"/' "${ATMO_HOME}/config/genesis.json"
      atmod keys add validator --keyring-backend test --home "${ATMO_HOME}" --no-backup || true
      atmod genesis add-genesis-account validator 10000000000000uatmo --keyring-backend test --home "${ATMO_HOME}"
      atmod genesis gentx validator 1000000000000uatmo --chain-id "${CHAIN_ID}" --keyring-backend test --home "${ATMO_HOME}"
      atmod genesis collect-gentxs --home "${ATMO_HOME}"
      ;;
    peer)
      if [ -z "${GENESIS_URL}" ]; then echo "ERROR: set GENESIS_URL"; exit 1; fi
      mkdir -p "${ATMO_HOME}/config"
      curl -fsSL "${GENESIS_URL}" | jq -r '.result.genesis // .' > "${ATMO_HOME}/config/genesis.json"
      ;;
    *) echo "Unknown JOIN_MODE=${JOIN_MODE}"; exit 1;;
  esac
  sed -i 's/^minimum-gas-prices = .*/minimum-gas-prices = "'"${MIN_GAS_PRICE}"'"/' "${ATMO_HOME}/config/app.toml" || true
  if [ -n "${PERSISTENT_PEERS}" ]; then
    sed -i -E 's/^persistent_peers *=.*/persistent_peers = "'"${PERSISTENT_PEERS}"'"/' "${ATMO_HOME}/config/config.toml"
  fi
  if [ -n "${EXTERNAL_ADDRESS}" ]; then
    sed -i -E 's/^external_address *=.*/external_address = "'"${EXTERNAL_ADDRESS}"'"/' "${ATMO_HOME}/config/config.toml"
  fi
  atmod genesis validate --home "${ATMO_HOME}" || true
fi
exec atmod start --home "${ATMO_HOME}"
