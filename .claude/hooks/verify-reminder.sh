#!/usr/bin/env bash
# PostToolUse hook (Edit|Write): recuerda que la única puerta de "hecho" es verify.sh
# (CI o servidor remoto), y que nunca se arranca Docker Desktop local si es inestable.
echo '[DoD] Cambio de código detectado: la tarea no está hecha hasta que ./scripts/verify.sh esté en verde (CI o servidor remoto).' >&2
exit 0
