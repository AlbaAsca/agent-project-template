# CLAUDE.md — Guía para el agente (desarrollo desatendido)

Eres el desarrollador autónomo de **<PROJECT>**. Lee este archivo al empezar CADA sesión.
Referencia completa en `STANDARD.md`; lecciones de infra en `docs/LESSONS.md`.

## Stack (no cambiar sin checkpoint)
- **<STACK>** — describe aquí lenguaje/framework/versión de cada módulo y su carpeta.
- Datos / infra: <BD, colas, storage…> (ver `docker-compose.yml`).
- Tests: <runner unit> (unit) + Playwright u otro (e2e), si aplica.

## Regla de oro
<La invariante de negocio/diseño no negociable del proyecto. Ej: "el handoff de diseño es
la única fuente de verdad; toda mutación pasa por el `repository`".>

## Flujo de trabajo (bucle autónomo)
1. Coge la primera tarea NO marcada de `TASKS.md` con dependencias resueltas (`(dep: X)`).
2. **TDD**: escribe primero el test que codifica su criterio de aceptación (debe fallar).
3. Implementa el mínimo código para que pase.
4. Ejecuta `./scripts/verify.sh` (build + tests + lint). Corre en local rápido con el
   toolchain instalado; si no está, usa CI como puerta real (ver "Comandos").
5. Si falla, corrige (máximo **4 intentos**). Si se agotan, PARA y escribe el bloqueo
   al final de `TASKS.md` bajo "## BLOQUEOS".
6. Si pasa: commit atómico (Conventional Commits, inglés) en rama `feature/<slug>` y
   abre PR contra `develop`. **NO marques la tarea todavía.**
7. Mientras el PR espera merge:
   - Continúa con la siguiente tarea que NO dependa de la que espera merge.
   - **Paralelismo**: tareas sin dependencia mutua pueden lanzarse en paralelo.
8. Tras el merge: marca el `[x]` en `TASKS.md`. **Batchea las marcas por fase** en un único
   PR `docs/mark-<fase>-done` (no un PR de docs por tarea). Solo entonces cuenta como hecha.
9. Repite. Al cerrar una sesión no trivial, actualiza `docs/state.md` (`/close-session`).

## Orquestación (cuando actúas de orquestador)
NO toques código: delega cada tarea al subagente `implementer`, pasa su resultado al
`reviewer`, y gestiona el bucle (máx. 2 rondas de correcciones, luego BLOQUEO). Ver `STANDARD.md` §5.
- **Aislamiento**: lanza cada `implementer`/`reviewer` con `isolation: "worktree"` para que
  trabajen en su copia sin ocupar el checkout principal (evita errores "branch used by worktree").
- **Verificación local rápida**: instruye a cada implementer a tener el toolchain en PATH para
  verificar en segundos; CI es la puerta final de "hecho".
- **Corte por fase**: orquestador residente dentro de una fase; corte limpio entre fases con
  handoff explícito (evita que el contexto crezca sin techo).

## Definición de Hecho (DoD)
- [ ] Existe un test que cubre el criterio de aceptación de la tarea.
- [ ] `./scripts/verify.sh` pasa en verde (confirmado en CI real).
- [ ] PR de feature mergeado + `[x]` en `TASKS.md` (PR de docs batcheado por fase).
- [ ] Commits `tipo(scope): descripción`.

## Guardarraíles (NUNCA)
- NUNCA secretos/credenciales reales; usa `.env.example` y variables de entorno.
- NUNCA migraciones destructivas ni borrado de datos salvo tarea explícita.
- NUNCA dependencias nuevas ni cambio de stack sin checkpoint humano.
- NUNCA marques una tarea hecha sin cumplir la DoD completa.
- NUNCA ablandes o borres un test para que pase; el criterio de `TASKS.md` es fijo.
- NUNCA servicios de pago (LLM externo, APIs facturables) en tests: usa mocks.
- NUNCA arranques Docker Desktop local si es inestable; verificación por CI/servidor remoto.

## Checkpoints (PARA y pide revisión humana, salvo autorización explícita para continuar)
- Al terminar cada fase.
- Antes de despliegues o de conectar datos/servicios reales.
- Ante cambios de esquema de datos o del contrato del `repository`/API.
- Cuando reportes un BLOQUEO.
- Fases que introduzcan **stack nuevo, credenciales o costes reales** (p.ej. backend, cloud):
  requieren confirmación explícita SIEMPRE, aunque haya autorización para saltar otros checkpoints.

## RAG / servidor de IA local (Regla #0 — ver `docs/LESSONS.md` §RAG y `~/.claude/CLAUDE.md`)
- **Conéctate por PowerShell** (OpenSSH nativo), NO por el Bash tool (su ssh puede hacer timeout).
  Conexión intermitente → reintenta 3-6 veces.
- Registra el repo (`nuevo-proyecto` / `indexar.py`) para que el RAG lo cubra; resincroniza tras merges.
- Antes de resolver un BUG/INFRA: `buscar-solucion.py`. Localizar código: `preguntar.py --repo <PROJECT>`.
- Cierre no trivial → `guardar-solucion.py` tras OK del usuario (texto conflictivo en base64).

## Comandos
- Verificar todo: `./scripts/verify.sh` (modo `docker` por defecto, `native` en CI).
- **Toolchain local**: documenta aquí cómo poner tu runtime en PATH para verificar rápido en local.
- CI (puerta de "hecho"): jobs `verify` + `e2e` (dentro de contenedor oficial, ver `docs/LESSONS.md`)
  + `deploy` (preview en runner autoalojado). Los tres deben quedar verdes.

## Referencia
- Decisiones de diseño: `docs/architecture.md` · Estado actual: `docs/state.md`
- Lecciones de infra/proceso: `docs/LESSONS.md` · Estándar completo: `STANDARD.md`
