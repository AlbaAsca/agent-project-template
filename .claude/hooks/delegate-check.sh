#!/usr/bin/env bash
# PreToolUse hook (Bash): recuerda delegar SOLO trabajo mecánico en volumen al proxy
# LiteLLM local. NO dispara en cada `git commit` (bajo ROI: un mensaje de commit ya es
# barato). Solo avisa ante señales de trabajo mecánico repetitivo real. No bloquea (exit 0).
INPUT=$(cat)
if echo "$INPUT" | grep -qiE 'for .* in .*(docstring|boilerplate|scaffold)'; then
  echo '[Regla #0] Trabajo mecánico en volumen: valora delegarlo al proxy LiteLLM local (local-3b/auto) vía PowerShell-SSH.' >&2
fi
exit 0
