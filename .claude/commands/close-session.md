---
description: Cierra la sesión — actualiza state.md, batchea los [x] de PRs mergeados, destila soluciones al RAG
---

Cierra la sesión actual con este checklist:

1. **PRs mergeados sin marcar**: batchea los `[x]` de las tareas ya mergeadas en un único
   PR `docs/mark-<fase>-done` (commit `docs(tasks): mark <ids> done (#<PRs>)`), contra `develop`.
2. **docs/state.md**: actualiza fase actual, tarea activa, decisiones cerradas en esta
   sesión, alcance diferido y bloqueos. Solo cambios estructurales, no un diario.
3. **RAG**: si la sesión resolvió algo no trivial (sobre todo bugs/infra), destila la
   solución (pregunta → solución, tal como la formularía el usuario la próxima vez),
   propónmela, y solo tras mi OK guárdala con `guardar-solucion.py` (por PowerShell; texto
   conflictivo en base64). Ver `docs/LESSONS.md` §RAG.
4. **Handoff**: si la próxima sesión arranca en contexto limpio, redacta el prompt de
   continuación (estado, siguiente tarea, notas de infra pendientes).
5. Resume en 3-5 líneas: qué quedó hecho, qué espera merge, cuál es la siguiente tarea.
