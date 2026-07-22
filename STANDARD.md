# STANDARD.md — Estándar de trabajo reutilizable

Copia esto tal cual a un proyecto nuevo y Claude Code trabaja con la misma disciplina:
TDD, commits atómicos convencionales, Git Flow, checkpoints humanos, verificación en
CI/servidor remoto, y **orquestación con contexto en archivos**. Los ejemplos de stack
son ilustrativos (marcados "ej."); el **método** es lo reutilizable.

---

## 1. Estructura de proyecto tipo

```
<repo>/
├── CLAUDE.md               # guía del agente (se lee cada sesión, <150 líneas)
├── TASKS.md                # backlog atómico, fuente de verdad del progreso, agrupado en sesiones
├── STANDARD.md             # este fichero
├── README.md
├── docs/
│   ├── architecture.md     # decisiones de diseño (el "porqué")
│   ├── state.md            # estado actual: handoff entre sesiones
│   └── LESSONS.md          # lecciones de infra/proceso ganadas a golpes
├── scripts/
│   └── verify.sh           # única puerta de "hecho": build + test + lint, modo docker|native
├── docker-compose.yml      # despliegue de preview (o infra de desarrollo)
├── .github/workflows/ci.yml
└── .claude/
    ├── settings.json       # hooks (UserPromptSubmit, PreToolUse, PostToolUse)
    ├── hooks/              # scripts de los hooks (bash)
    ├── agents/             # subagentes: implementer.md, reviewer.md
    └── commands/           # comandos slash: /next-task, /close-session
```

Reglas consistentes:
- **Un paquete/carpeta por dominio funcional**, no por capa técnica salvo las transversales.
- Los tests replican la ubicación de la unidad bajo test (co-ubicados o paquete espejo).
- `scripts/verify.sh` es la única puerta de calidad citada en commits y en CLAUDE.md.
- El contexto vive en archivos (CLAUDE.md / TASKS.md / docs/), nunca solo en la conversación (§5).

---

## 2. Convenciones de nombres y estilo

- **Todo el naming en inglés** (código, tests, ramas, commits), sin importar el idioma de
  la conversación.
- Tests: el nombre describe el escenario completo, sin prefijo `test` — ej.
  `doesNotCallLlmWhenThereAreNoHeadings`, `filtersByStatusChip`.
- Comentarios solo cuando explican un **porqué no obvio**, en inglés. Nunca comentarios que
  repiten lo que el código ya dice.
- **Puertos hacia servicios externos** (LLM, IO, pagos): interfaz + implementación real como
  tarea aparte. No registres un bean/servicio sobre un puerto sin implementación (rompe el
  contexto de los tests de integración). — ej. patrón backend Java/Spring.
- Frontend (ej. React+TS): componentes con tests co-ubicados (`*.test.tsx`), e2e en `e2e/*.spec.ts`;
  `npm run build` incluye chequeo de tipos (falla el build si hay error de tipos).

---

## 3. Formato de commits y flujo de ramas

### Conventional Commits (todo en inglés)
- `feat(<scope>): <qué añade>`, `fix(<scope>): <qué corrige>`, `test(...)`, `chore:`, `ci:`, `docs:`.
- `docs(tasks): mark <ids> done (#<PRs>)` — commit dedicado a marcar TASKS.md, **batcheado por fase**.

### Ramas — Git Flow estricto
- `main` = producción. `develop` = integración. **Nunca se trabaja directo en `develop`/`main`**.
- `feature/<slug>`, `fix/<slug>`, `docs/<slug>`, `chore/<slug>`, `release/<version>`.
- El slug describe **qué hace la rama**, sin ID de tarea (el ID vive en TASKS.md y el commit).
- Cada feature/fix pasa por **PR contra `develop` con CI en verde** antes de merge. Rama borrada tras merge.
- El **merge lo confirma el humano** — salvo autorización explícita para que el agente mergee.
- **Marcar `[x]` en TASKS.md** va en un PR de docs separado, **batcheado por fase**
  (`docs/mark-<fase>-done`), abierto tras el/los merge(s) de feature — nunca en el mismo commit que el código.

---

## 4. Patrones obligatorios

### TDD estricto
1. Test que codifica el criterio de aceptación de TASKS.md — debe fallar.
2. Mínimo código para pasarlo.
3. `verify.sh` (build + test + lint). Con el toolchain en PATH corre en local en segundos;
   si no, CI es la puerta real.
4. Máximo **4 intentos** de arreglo; si se agotan, escribir el bloqueo en TASKS.md § BLOQUEOS y parar.
5. Commit atómico, PR. El `[x]` es siempre un PR de docs posterior al merge (ver §3).

### Mocking de LLM/servicios de pago
**Nunca LLM real ni servicio facturable en tests.** Puerto (interfaz) + mock. La implementación
real del puerto es tarea aparte.

### Verificación: nunca local frágil, siempre CI/servidor remoto
- `verify.sh` soporta `docker` (contenedores efímeros) y `native` (CI/local con toolchain).
- Si Docker Desktop local es inestable, **nunca se arranca desde el agente**; verificación por
  CI con runner autoalojado o SSH a servidor remoto.
- CI encadena `verify → e2e → deploy`; deploy solo en push a `develop`/`main` en verde.
- **Los fixes de CI para runner autoalojado (Playwright sin sudo, ownership del workspace,
  puertos) están en `docs/LESSONS.md` y ya aplicados en el workflow — no los quites sin entenderlos.**

### RAG / servidor de IA local (Regla #0)
- **Conexión por PowerShell**, no por el Bash tool (su ssh puede hacer timeout). Conexión
  intermitente → retry 3-6 veces. Ver `docs/LESSONS.md` §RAG.
- Registra el repo para que el RAG lo indexe; resincroniza tras merges.
- Antes de un BUG/INFRA: `buscar-solucion.py`. Localizar código: `preguntar.py --repo <PROJECT>`.
- Cierre no trivial → `guardar-solucion.py` tras OK (texto conflictivo en base64).
- Los hooks de `.claude/` automatizan estos recordatorios — replícalos en cada proyecto.

---

## 5. Orquestación y gestión de contexto

Principio: **el contexto de la conversación es efímero y caro; el estado del proyecto vive en
archivos.** CLAUDE.md (permanente), TASKS.md (el qué + progreso), docs/state.md (handoff),
docs/architecture.md (el porqué), docs/LESSONS.md (infra).

### Patrón orquestador → subagentes
La sesión principal **nunca toca código**: lee TASKS.md, delega y verifica.
- `implementer` — implementa UNA tarea con TDD. Devuelve solo un resumen.
- `reviewer` — solo lectura. Audita contra el criterio de TASKS.md y este estándar. APPROVE/REJECT.
- Bucle: tarea → implementer → reviewer → (REJECT: correcciones, máx. 2 rondas, luego BLOQUEO) →
  (APPROVE: PR) → merge → `[x]` batcheado por fase.
- **Aislamiento**: lanza los subagentes con `isolation: "worktree"` para no competir por el checkout.
- **Paralelismo**: tareas sin dependencia mutua (anotada `(dep: X)` en TASKS.md) corren en paralelo.
- **Corte por fase**: orquestador residente dentro de una fase; handoff limpio entre fases.

---

## 6. Definición de "tarea completada"

Una tarea se marca `[x]` **solo** cuando, en este orden:
1. Existe un test que cubre el criterio de aceptación exacto (no relajado).
2. `verify.sh` en verde — **confirmado en CI real**.
3. PR de feature mergeado.
4. `[x]` marcado en el PR de docs batcheado por fase, con nota del PR/commit y alcance diferido.
5. Si la tarea es un `CHECKPOINT`: va al final de la fase y **requiere aprobación humana explícita**
   (o autorización previa del usuario para continuar). Fases con stack nuevo/credenciales/costes
   reales requieren confirmación SIEMPRE.

Guardarraíles: nunca dependencias nuevas ni cambio de stack sin checkpoint; nunca migraciones
destructivas; nunca ablandar/borrar un test para forzar el verde; nunca LLM de pago en tests.
