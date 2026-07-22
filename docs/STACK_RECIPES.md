# STACK_RECIPES.md — Adaptar la plantilla a tu stack

El método (CLAUDE.md, STANDARD.md, agentes, hooks, flujo de CI) es agnóstico de stack. Solo
cambian tres piezas: `scripts/verify.sh`, los jobs de `.github/workflows/ci.yml`, y el
`Dockerfile`/`docker-compose.yml`. Aquí tienes recetas drop-in. El ejemplo por defecto del
repo es **React + Vite** (frontend estático); sustituye por la receta que corresponda.

---

## React + Vite + TypeScript (por defecto en el repo)

- `verify.sh` → `run_frontend`: `npm ci && npm run lint && npm run build && npm test -- --run`.
- CI: job `e2e` con Playwright **dentro del contenedor oficial** (ver docs/LESSONS.md); `deploy`
  sirve el build de Vite con nginx.
- Ya está todo puesto en el repo — no tienes que hacer nada salvo reemplazar los marcadores.

---

## Java + Maven + Spring Boot (ej. estilo `oposia`)

`scripts/verify.sh` → usa `run_backend` (ya incluido como ejemplo). Versión con cobertura:

```bash
run_backend() {
  [ -f "$ROOT/backend/pom.xml" ] || { echo "(sin backend)"; return 0; }
  if [ "$MODE" = "native" ]; then
    (cd "$ROOT/backend" && ./mvnw -q verify jacoco:check)
  else
    docker run --rm -v "$ROOT/backend":/app -w /app -v "$HOME/.m2":/root/.m2 \
      maven:3.9-eclipse-temurin-21 mvn -q verify jacoco:check
  fi
}
```

CI — sustituye el job `e2e` (Playwright no aplica a un backend puro) por `verify` con JDK, o
si hay integración con Testcontainers, déjalo dentro de `verify`:

```yaml
  verify:
    runs-on: [self-hosted, <RUNNER_LABEL>]
    timeout-minutes: 20
    steps:
      - name: Reclaim root-owned files in the workspace   # ver docs/LESSONS.md
        run: |
          docker run --rm -v "$GITHUB_WORKSPACE":/w alpine \
            sh -c 'chown -R "$(stat -c "%u:%g" /w)" /w' || true
      - uses: actions/checkout@3d3c42e5aac5ba805825da76410c181273ba90b1 # v7.0.1
      - uses: actions/setup-java@<pin-sha>   # temurin 21, cache: maven
        with: { distribution: temurin, java-version: "21", cache: maven }
      - run: ./scripts/verify.sh native
```

- Testcontainers necesita Docker en el runner (ya disponible sin sudo). Corre en el host, no
  metas `verify` dentro de un `container:` o el Docker-in-Docker se complica.
- `deploy`: `Dockerfile` de dos stages (build con `maven`, runtime con `eclipse-temurin-21-jre`),
  y `docker-compose.yml` con el jar + su BD (Postgres) si aplica.

---

## Python (FastAPI / Django / librería)

`scripts/verify.sh` → `run_backend`:

```bash
run_backend() {
  [ -f "$ROOT/pyproject.toml" ] || { echo "(sin backend)"; return 0; }
  if [ "$MODE" = "native" ]; then
    (cd "$ROOT" && pip install -q -e ".[dev]" && ruff check . && mypy . && pytest -q)
  else
    docker run --rm -v "$ROOT":/app -w /app python:3.12-slim \
      bash -c "pip install -q -e '.[dev]' && ruff check . && mypy . && pytest -q"
  fi
}
```

CI: job único `verify` con `actions/setup-python`. Sin `e2e` salvo que sirvas una UI.

---

## Regla común a todos los stacks

- Mantén los pasos de **reclaim de ownership del workspace** en cualquier job de host y el
  **chown final** en cualquier job que corra en `container:` como root — es lo que evita los
  fallos de checkout con EACCES en el runner autoalojado (docs/LESSONS.md §CI).
- Pinea las Actions por SHA (como en el workflow de ejemplo) y añade `dependabot.yml` si quieres
  mantenerlas al día.
- `verify.sh` siempre soporta `docker` (por defecto) y `native` (CI): mismo comando, dos entornos.
