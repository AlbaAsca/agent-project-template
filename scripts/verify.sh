#!/usr/bin/env bash
# Única puerta de "hecho": build + test + lint de todos los módulos.
# Modos: docker (por defecto, contenedores efímeros) | native (CI/local con toolchain instalado).
# Adapta run_* a tu stack. Cada run_* es no-op si su módulo aún no existe (arranque incremental).
set -euo pipefail
MODE="${1:-docker}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

run_frontend() {
  if [ ! -f "$ROOT/frontend/package.json" ]; then
    echo "(sin frontend todavía)"; return 0
  fi
  if [ "$MODE" = "native" ]; then
    (cd "$ROOT/frontend" && npm ci --silent && npm run lint && npm run build && npm test -- --run)
  else
    docker run --rm -v "$ROOT/frontend":/app -w /app node:22-slim \
      bash -c "npm ci --silent && npm run lint && npm run build && npm test -- --run"
  fi
}

run_backend() {
  # Ejemplo (Maven/JDK). No-op mientras backend/ no tenga build real. Reemplaza por tu stack.
  if [ ! -f "$ROOT/backend/pom.xml" ]; then
    echo "(sin backend todavía)"; return 0
  fi
  if [ "$MODE" = "native" ]; then
    (cd "$ROOT/backend" && ./mvnw -q verify)
  else
    docker run --rm -v "$ROOT/backend":/app -w /app \
      -v "$HOME/.m2":/root/.m2 maven:3.9-eclipse-temurin-21 mvn -q verify
  fi
}

echo "== verify ($MODE): frontend =="
run_frontend
echo "== verify ($MODE): backend =="
run_backend
echo "== verify: OK =="
