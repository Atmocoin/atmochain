#!/usr/bin/env bash
set -e
docker compose build --no-cache
docker compose up -d
echo "Node is starting. Check logs: docker compose logs -f"
