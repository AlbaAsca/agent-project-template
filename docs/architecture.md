# architecture.md — Decisiones de diseño (el "porqué")

Registra aquí el porqué de las decisiones estructurales, no el qué (eso está en el código
y en TASKS.md). Una entrada por decisión no obvia.

## Stack y estructura
- <por qué este stack, esta separación de módulos, este límite de responsabilidades>.

## Capa de datos / repository
- <por qué toda mutación pasa por una interfaz `repository`/puerto; cómo se sustituirá por API/BD real>.

## Contrato local ↔ destino (si migras a cloud más adelante)
- <tabla: pieza local ahora | equivalente destino | regla de diseño que garantiza la migración>.

## Decisiones cerradas con fecha
- YYYY-MM-DD — <decisión> — <alternativas descartadas y por qué>.
