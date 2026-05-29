#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

docker compose up -d mysql || docker-compose up -d mysql

echo "Waiting for MySQL to become healthy..."
for i in $(seq 1 60); do
  status="$(docker inspect --format '{{.State.Health.Status}}' davinci-mysql 2>/dev/null || true)"
  if [ "$status" = "healthy" ]; then
    echo "MySQL is ready."
    exit 0
  fi
  sleep 3
done

echo "MySQL did not become healthy in time. Check: docker logs davinci-mysql" >&2
exit 1
