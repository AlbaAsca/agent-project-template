# state.md — Estado actual del proyecto
_Actualizar solo en checkpoints o cambios estructurales; no es un diario._

## Fase actual
Fase 0 — Fundaciones. Tarea activa: T0.1.

## Decisiones cerradas (no reabrir sin checkpoint)
- Estándar de trabajo: STANDARD.md (TDD, Git Flow, PR de docs batcheado por fase).
- <añade aquí las decisiones cerradas de tu proyecto>.

## Alcance explícitamente diferido
- <qué se dejó fuera> → <fase/tarea futura que lo recoge>.

## Bloqueos activos
(vacío o enlace a TASKS.md § BLOQUEOS)

## Infraestructura
- Verificación: CI (runner autoalojado) / servidor remoto. Nunca Docker Desktop local si es inestable.
- Despliegue: push a develop con verify en verde → preview Docker en el runner (puerto <PORT>).
- RAG local: <indexado sí/no> — conexión por PowerShell (ver docs/LESSONS.md §RAG).
