# TASKS.md — Backlog atómico completo de <PROJECT> (Fases 0–N)

Marca `[x]` cada tarea SOLO cuando cumpla la Definición de Hecho (CLAUDE.md).
Trabaja de arriba abajo, respetando dependencias. No trabajes nada que no esté aquí.
Las tareas se agrupan en **sesiones** (~1 sesión de trabajo del agente cada una);
no empieces una sesión nueva sin cerrar o bloquear la anterior.

**Fuente de verdad:** <handoff de diseño / especificación de tu proyecto>.

Formato:  `- [ ] ID Descripción → CRITERIO VERIFICABLE`

**Dependencias y paralelismo:** una tarea puede anotar de qué otras depende con `(dep: Tx.y)`.
Sin anotación, se asume que solo depende de la tarea anterior de su sesión. Las tareas que NO
dependen entre sí pueden lanzarse en paralelo (varios `implementer` a la vez). El marcado `[x]`
se batchea por fase en un único PR `docs/mark-<fase>-done` (ver CLAUDE.md §Flujo, paso 8).
---

## Fase 0 — Fundaciones y verificación

### Sesión 0.A
- [ ] T0.1 Scaffolding del stack elegido + estructura de carpetas → arranca en local.
- [ ] T0.2 `scripts/verify.sh` (build + test + lint) → `verify.sh native` exit 0.

### Sesión 0.B
- [ ] T0.3 CI (`.github/workflows/ci.yml`) ejecuta `verify.sh` en el runner → job `verify`
      verde en un push de prueba. (dep: T0.2)
- [ ] T0.4 CHECKPOINT: fundaciones revisadas — revisión humana.

## Fase 1 — <primer dominio funcional>

### Sesión 1.A
- [ ] T1.1 <tarea atómica> → <criterio verificable, específico y falsable>.
- [ ] T1.2 <tarea> → <criterio>. (dep: T1.1)
- [ ] T1.3 CHECKPOINT: contrato de datos de <dominio> — revisión humana.

<!-- Repite el patrón fase por fase. Una fase = un bloque coherente cerrable con checkpoint. -->

---
## BLOQUEOS
(El agente añade aquí cualquier tarea bloqueada tras 4 intentos, con el detalle del error
y la acción pendiente del humano si es de infraestructura.)
