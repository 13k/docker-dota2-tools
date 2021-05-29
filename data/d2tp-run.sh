#!/bin/bash

set -eux

stage_path="${STEAM_DIR:?}/.d2tp"
build_path="${stage_path}/proton"
prefix_path="${stage_path}/prefix"

exec "${D2TP_BIN:?}" \
  --proton "${PROTON_PATH:?}" \
  --game "${DOTA2_PATH:?}" \
  --build "$build_path" \
  --prefix "$prefix_path" \
  -- \
  "$@"
