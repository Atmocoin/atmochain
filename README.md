
# AtmoChain (на базі Cosmos SDK / CometBFT) — **Fixed Build**

**Готовий каркас ноди**, який збирає еталонний застосунок `simd` з Cosmos SDK (`v0.53.4`) у бінарій `atmod` і запускає його в Docker.  
Працює на **Windows** та **Linux** без зайвих танців.

## Що змінено у цій версії
- Оновлено Go-базовий образ до **golang:1.23.3** (SDK вимагає ≥ 1.23.2).
- Збірка через **`make build`** (правильна ціль для `simd`), далі бінарій інсталюється як `atmod`.
- У `entrypoint.sh` після `init` автоматично міняємо **усі `stake` → `uatmo`** у `genesis.json` — тепер `gentx` одразу працює у вашому деномі.
- Прибрано застаріле поле `version:` з `docker-compose.yml` (Compose v2).
- README, скрипти та коментарі — українською.

## Швидкий старт (Linux/macOS)
```bash
./scripts/run.sh
docker compose logs -f
# Зупинка:
./scripts/stop.sh
```

## Швидкий старт (Windows 10/11)
Відкрий **CMD** (не подвійним кліком `.bat`!), перейдіть у теку проекту і запустіть:
```
cd "C:\Users\...\atmochain"
scripts\run.bat
```
У вікні буде **пауза** та вивід логів. Для живих логів:
```
docker compose logs -f
```

## Що робить перший запуск
- `atmod init` із `chain-id=atmochain-1` та монікером `atmo-validator`.
- Замінює `stake` на `uatmo` у `genesis.json` (узгодженість деному).
- Створює ключ `validator`, видає **100 000 000 uatmo**, генерує `gentx` на **50 000 000 uatmo** і збирає `genesis`.
- Встановлює **minimum-gas-prices = 0.005uatmo** у `app.toml`.

## Порти
- `26657` — RPC, `26656` — P2P, `1317` — REST (за потреби), `9090` — gRPC.

## Корисні команди
```bash
docker compose ps
docker compose logs -f
docker exec -it atmochain atmod status
docker exec -it atmochain atmod version
docker exec -it atmochain atmod keys list --keyring-backend test --home /home/atmo/.atmo_home
```

## Далі (для ATMO/PoUW)
1. Перейменувати деном (за потреби), оновити генезис.
2. Підключити IBC.
3. Додати власні модулі (PoUW) поверх `simapp` або замінити застосунок.
4. Налаштувати **Cosmovisor** для апґрейдів.

---

### Ліцензія
Скрипти/обгортки — © 2025. Upstream **Cosmos SDK** — **Apache‑2.0**.
