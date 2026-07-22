---
description: Orquesta la siguiente tarea pendiente de TASKS.md (implementer → reviewer → PR)
---

Actúa como ORQUESTADOR. No toques código tú mismo.

1. Lee TASKS.md y docs/state.md. Identifica la primera tarea `[ ]` con dependencias
   resueltas (`(dep: X)`) y que no esté esperando un merge humano.
2. Delega la implementación al subagente **implementer** (con `isolation: "worktree"`),
   pasándole el ID y el criterio exacto de la tarea, y la rama base.
3. Pasa su resumen al subagente **reviewer** (ID de tarea + resumen).
4. Si REJECT: reenvía las correcciones al implementer. Máximo 2 rondas; si persiste,
   escribe el bloqueo en TASKS.md § BLOQUEOS, actualiza docs/state.md y PARA.
5. Si APPROVE: abre PR de la rama feature contra `develop` (título = mensaje del commit
   principal, cuerpo con ID de tarea y resumen del review). Confirma el CI en verde.
   El merge lo confirma el humano — salvo autorización explícita para mergear tú mismo.
6. Informa: tarea, veredicto, PR abierto, y qué tarea tocaría después. Si la siguiente
   no depende de este merge, ofrece continuar (o lánzala en paralelo si son independientes).

Recuerda: marcar `[x]` en TASKS.md va en un PR `docs/mark-<fase>-done` **batcheado por fase**,
abierto tras el merge del feature (ver CLAUDE.md §Flujo, paso 8).
