# LESSONS.md — Lecciones ganadas a golpes (infra + proceso)

Cosas que costaron sesiones enteras descubrir. Léelas ANTES de repetir el error.

## RAG / servidor de IA local

- **La conexión SSH va por PowerShell, no por el Bash tool.** El `ssh`/`nc` del Bash tool
  puede hacer *timeout* por su stack de red aunque el servidor esté perfectamente vivo.
  Comprueba con `Test-NetConnection -ComputerName <IP> -Port 22` (PowerShell) antes de
  concluir "no hay conexión". Ejecuta el RAG así:
  ```powershell
  ssh -o ConnectTimeout=15 -o BatchMode=yes alba@<IP> "<cmd>"
  ```
- **La conexión puede ser intermitente** (si el servidor es un portátil en WiFi):
  envuelve cada SSH en un retry de 3-6 intentos (fallo = exit 255).
- **El RAG solo cubre repos sincronizados al servidor.** Un repo greenfield NO está
  indexado hasta que lo registras. Para sincronizar sin la función local:
  ```bash
  git clone <checkout-del-runner-o-github> ~/projects/<PROJECT>
  ~/ia-local/rag/.venv/bin/python ~/ia-local/rag/nuevo-proyecto.py ~/projects/<PROJECT> --repo <PROJECT> --sin-hook
  ```
  Resincroniza tras merges en develop: reclona/pull y `indexar.py ~/projects/<PROJECT>`.
- **ROI honesto**: `buscar-solucion.py` casi siempre dirá "procede" en features de primera
  implementación (no hay nada guardado aún). Donde SÍ paga es en **bugs e infra**: guarda
  ahí las soluciones no triviales. `preguntar.py` sobre el código rinde cuando el repo ya es grande.
- **Texto con comillas/shell conflictivo** al pasar por SSH/PowerShell: codifícalo en
  **base64** para que no lo intercepte el clasificador de seguridad ni rompa el quoting.

## Verificación local rápida

- No dependas solo de round-trips de CI (~30 s-2 min cada uno) para el ciclo TDD del
  implementer. Ten el runtime disponible en local (un runtime portable en una carpeta,
  añadido al PATH de la sesión) y corre `verify.sh`/tests en segundos. **CI sigue siendo
  la puerta final de "hecho".**

## Orquestación con subagentes

- Lanza `implementer`/`reviewer` con **`isolation: "worktree"`** (Agent tool). Si no, todos
  compiten por el checkout principal y aparecen errores tipo *"cannot delete branch used by
  worktree"* al mergear, y hay que montar un worktree manual aparte.
- Mantén el orquestador residente **dentro de una fase** (comparten contexto) y haz **corte
  limpio entre fases** con un handoff explícito, para que el contexto no crezca sin techo.
- El `reviewer` se gana el sueldo: caza REJECTs reales (filtros mal aplicados, SHAs mal
  pinneados en workflows). Pero verifica CI de verdad (`gh run view`), no te fíes del resumen.

## Ceremonia de merges

- Marcar `[x]` con un PR de docs **por tarea** duplica los merges. **Batchea por fase**: un
  único `docs/mark-<fase>-done` al cerrar la fase.
- Anota **dependencias explícitas** en TASKS.md (`(dep: X)`) para poder paralelizar lo independiente.

## CI en runner autoalojado — los tres fixes que costaron sangre

Todos están ya aplicados en `.github/workflows/ci.yml` de esta plantilla:

1. **Playwright sin sudo.** `npx playwright install --with-deps` requiere sudo interactivo,
   ausente en el runner. → Corre el job e2e **dentro del contenedor oficial**
   `mcr.microsoft.com/playwright:vX.Y.Z-noble` (mismo minor que `@playwright/test`), que ya
   trae los navegadores. Sin sudo, sin instalar nada en el host.
2. **Ficheros root-owned que rompen el checkout.** El contenedor de Playwright corre como
   root y deja `node_modules/`, `test-results/`, `playwright-report/` con propiedad root en
   el workspace compartido; el usuario no-root del runner ya no puede limpiarlos y
   **todo checkout posterior falla con EACCES**. → (a) paso final en e2e que hace
   `chown -R` del workspace al owner del host; (b) paso defensivo ANTES del checkout en los
   jobs de host que reclama el árbol vía contenedor efímero
   (`docker run --rm -v "$GITHUB_WORKSPACE":/w alpine sh -c 'chown -R "$(stat -c "%u:%g" /w)" /w' || true`).
   Docker está disponible **sin sudo** en el runner: úsalo para reclamar sin tocar la config del servidor.
3. **Puerto ocupado en deploy.** `docker compose up` falla con *"port is already allocated"*
   si un contenedor huérfano retiene el puerto. → paso previo `docker compose down
   --remove-orphans` + `docker rm -f` de cualquier contenedor publicando ese puerto, y
   `--force-recreate` al levantar.

Regla general: en un runner autoalojado compartido, **cualquier job que escriba en el
workspace como un usuario distinto al del runner romperá los checkouts siguientes**. Deja
siempre el workspace con la propiedad del usuario del runner.
