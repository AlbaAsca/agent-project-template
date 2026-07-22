#!/usr/bin/env bash
# UserPromptSubmit hook: recuerda la Regla #0 (RAG antes de leer/resolver) con la vía de
# conexión CORRECTA y sin exigir lo imposible. No bloquea; inyecta contexto.
# Reemplaza <PROJECT> por el nombre del repo en el servidor RAG y <IP> por el servidor.
# Lección clave (docs/LESSONS.md): el SSH va por PowerShell, no por el Bash tool.
cat <<'MSG'
[Regla #0 · RAG local] Si el servidor de IA local está disponible, cubre este repo.
- Conéctate por PowerShell, NO por el Bash tool (su ssh puede hacer timeout):
    ssh -o ConnectTimeout=15 -o BatchMode=yes alba@<IP> "<cmd>"
  Conexión intermitente (portátil/WiFi): reintenta 3-6 veces si falla (exit 255).
- Antes de resolver un BUG o tarea de INFRA: `buscar-solucion.py '<pregunta>'` (exit 0 = ya resuelta).
- Localizar en el código: `preguntar.py '<pregunta>' --repo <PROJECT> --modelo 7b` en vez de leer ficheros enteros.
- Cierre no trivial (bug/infra) + OK del usuario: `guardar-solucion.py --proyecto <PROJECT>` (texto conflictivo en base64).
- Si el repo no está indexado o el servidor no responde, dilo y sigue: no te bloquees.
Para features de primera implementación, `buscar-solucion.py` casi siempre dirá "procede".
MSG
exit 0
