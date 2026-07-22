# agent-project-template

Plantilla de proyecto para **desarrollo autónomo con Claude Code**. No es un scaffold de
código: es la **forma de trabajar** ya escrita — bucle orquestador→implementer→reviewer,
TDD estricto, Git Flow, CI con verify/e2e/deploy, hooks, subagentes y las lecciones ya
aprendidas en proyectos anteriores. Haz un proyecto nuevo desde aquí y el agente arranca
con disciplina desde el primer commit.

## Cómo usarla

**Opción A — GitHub template (recomendado):** este repo está marcado como *template*.
Pulsa **"Use this template" → Create a new repository** (privado), o por CLI:

```bash
gh repo create <mi-org>/<mi-proyecto> --private --template <tu-usuario>/agent-project-template
git clone https://github.com/<mi-org>/<mi-proyecto> && cd <mi-proyecto>
```

**Opción B — fork:** haz fork si quieres mantener el vínculo con la plantilla y recibir
mejoras del método con `git pull upstream`.

Después, en cualquiera de las dos:

1. Busca y reemplaza los marcadores `<PROJECT>`, `<STACK>`, `<RUNNER_LABEL>`, `<PORT>`,
   `<ORG>` en todos los ficheros (empieza por `CLAUDE.md` y `.github/workflows/ci.yml`).
2. Rellena `TASKS.md` con el backlog atómico de tu proyecto (formato explicado dentro).
3. Ajusta el `Dockerfile`/`docker-compose.yml`/`scripts/verify.sh` a tu stack real
   (los de ejemplo sirven un frontend estático React+Vite; están marcados como reemplazables).
4. Registra el repo en el RAG local si lo usas (ver `docs/LESSONS.md` §RAG).
5. Arranca: abre Claude Code en la carpeta y di *"inicia la siguiente tarea"* o `/next-task`.

## Qué incluye

| Fichero | Qué aporta |
|---|---|
| `CLAUDE.md` | Guía que el agente lee cada sesión: bucle de trabajo, DoD, guardarraíles, checkpoints, orquestación, RAG. **Se lee siempre.** |
| `STANDARD.md` | Estándar completo reutilizable: estructura, naming, commits, Git Flow, TDD, patrones, orquestación, DoD. |
| `TASKS.md` | Backlog atómico (fuente de verdad del progreso) con formato, convención de dependencias `(dep: X)` y sección BLOQUEOS. |
| `docs/state.md` | Handoff entre sesiones (estado actual, decisiones cerradas, bloqueos). |
| `docs/architecture.md` | El "porqué" de las decisiones de diseño. |
| `docs/LESSONS.md` | **Lecciones ganadas a golpes**: RAG por PowerShell, verificación local rápida, aislamiento por worktree, fixes de CI (Playwright, ownership del workspace, puertos). |
| `docs/STACK_RECIPES.md` | Recetas drop-in de `verify.sh`/CI/Docker por stack: React+Vite (default), Java+Maven/Spring, Python. |
| `docs/DESIGN_BRIEF.md` | Plantilla opcional para encargar un rediseño de UI implementable sin romper el contrato ni los tests. |
| `.claude/agents/` | Subagentes `implementer` (TDD, una tarea) y `reviewer` (solo lectura, APPROVE/REJECT). |
| `.claude/commands/` | `/next-task` (orquesta la siguiente tarea) y `/close-session`. |
| `.claude/hooks/` + `settings.json` | Recordatorios automáticos: Regla #0 (RAG), delegación, DoD. |
| `.github/workflows/ci.yml` | CI `verify → e2e → deploy` para runner autoalojado, con TODOS los fixes ya aplicados. |
| `scripts/verify.sh` | Única puerta de "hecho": build + test + lint (modo docker/native). |
| `Dockerfile`, `docker-compose.yml` | Despliegue de preview (ejemplo frontend estático, reemplazable). |

## Filosofía en una frase

El contexto de la conversación es efímero y caro; **el estado del proyecto vive en
archivos** (`CLAUDE.md`, `TASKS.md`, `docs/`). Los subagentes arrancan en frío, hacen una
cosa y devuelven un resumen; el hilo principal orquesta sin agotarse.
