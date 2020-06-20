#!/bin/bash
if [[ -z "${WAIT_FOR_HOST}" || -z "${WAIT_FOR_PORT}" ]]; then
  /scripts/server.sh
else
  WAIT_FOR_TIMEOUT="${WAIT_FOR_TIMEOUT:-default value}"
  /scripts/wait-for-it.sh --timeout=$WAIT_FOR_TIMEOUT $WAIT_FOR_HOST:$WAIT_FOR_PORT -- /scripts/server.sh
fi
