#!/usr/bin/env bash
set -euo pipefail

ATMO_HOME="${ATMO_HOME:-/home/atmo/.atmo_home}"
CHAIN_ID="${CHAIN_ID:-atmochain-1}"
MONIKER="${MONIKER:-atmo-validator}"
MIN_GAS_PRICE="${MIN_GAS_PRICE:-0.005uatmo}"

if [ ! -f "${ATMO_HOME}/config/genesis.json" ]; then
  echo ">> First run: initializing chain ${CHAIN_ID} at ${ATMO_HOME}"
  atmod init "${MONIKER}" --chain-id "${CHAIN_ID}" --home "${ATMO_HOME}"

  # Переводимо всі деноми "stake" на "uatmo", щоб бондинг/депозити відповідали нашому деному
  sed -i 's/"stake"/"uatmo"/g' "${ATMO_HOME}/config/genesis.json"

  # Створюємо ключ валідатора і видаємо початкові кошти
  atmod keys add validator --keyring-backend test --home "${ATMO_HOME}" || true
  atmod add-genesis-account validator 100000000uatmo --keyring-backend test --home "${ATMO_HOME}"

  # Створюємо gentx у нашому деномі
  atmod gentx validator 50000000uatmo --chain-id "${CHAIN_ID}" --keyring-backend test --home "${ATMO_HOME}"
  atmod collect-gentxs --home "${ATMO_HOME}"

  # Мінімальна ціна газу
  sed -i 's/^minimum-gas-prices = .*/minimum-gas-prices = "'"${MIN_GAS_PRICE}"'"/' "${ATMO_HOME}/config/app.toml"
fi

echo ">> Starting node..."
exec atmod start --home "${ATMO_HOME}"
