# AtmoChain — один репозиторій для Windows (Docker) і Linux (з Docker / без Docker)

**Публічний peer:** `cff19e7f4a09c7dbb5efff2ecca4e70b936a5f07@212.23.203.145:26656`  
**Genesis URL:** `http://212.23.203.145:26657/genesis`  
**Chain‑ID:** `atmochain-1` • **Denom:** `uatmo` • **Min gas:** `0.005uatmo`

---

## Вариант A — Windows (Docker) / Linux (Docker)

1) Скопіюй `.env.example` → `.env` (за замовчуванням уже JOIN_MODE=peer і правильні URL/peers).
2) Запуск:
   - Windows: `scripts\run.bat`
   - Linux/macOS: `./scripts/run.sh`
3) Логи: `docker compose logs -f`  
   Зупинка: `scripts\stop.bat` або `./scripts/stop.sh`

> Для локального тесту (1 вузол) в `.env` постав `JOIN_MODE=single`.

---

## Вариант B — Linux **без Docker** (нативний запуск)

На сервері без віртуалізації:
```bash
sudo apt update && sudo apt install -y git curl jq build-essential
# Встанови Go >= 1.23.x з https://go.dev/dl/ (якщо нема)
cd scripts/no-docker
chmod +x install_atmo_nodocker.sh
./install_atmo_nodocker.sh
# Запуск
~/.local/bin/atmod start --home ~/.atmo_home
```
Опціонально — systemd:
```bash
sudo cp scripts/no-docker/atmo.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now atmo
journalctl -u atmo -f
```

---

## Діагностика
```
docker compose ps            # якщо Docker-режим
docker compose logs -f
# або без Docker:
curl -s http://127.0.0.1:26657/status | jq .result.sync_info
~/.local/bin/atmod version
~/.local/bin/atmod tendermint show-node-id --home ~/.atmo_home
```

---

## Структура
- `docker/` — Dockerfile + entrypoint з режимами `single|peer`.
- `docker-compose.yml` — сервіс ноди.
- `scripts/` — запуск/стоп, плюс `no-docker/` для нативного режиму.
- `.env.example` — параметри мережі (peer/genesis/chain-id).
- `README.md`, `.gitignore`, `LICENSE`.

Готово для публічного використання: Windows (Docker), Linux (Docker), Linux (no Docker).
