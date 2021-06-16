#!/bin/bash

set -e

STEAMCMD="${STEAMCMD_DIR:?}/steamcmd.sh"
STEAM_USER_FILE="${STEAMCMD_DIR:?}/.steam_user"
STEAM_PLATFORM_WINDOWS="windows"
STEAM_PLATFORM_LINUX="linux"

if [[ -n "$STEAM_USER" ]]; then
  echo -n "$STEAM_USER" >"${STEAM_USER_FILE:?}"
else
  if [[ ! -f "${STEAM_USER_FILE:?}" ]]; then
    echo >&2 "STEAM_USER not set"
    exit 1
  fi

  STEAM_USER="$(cat "${STEAM_USER_FILE:?}")"
fi

run_steamcmd() {
  local login_cmd="+login ${STEAM_USER:?}"
  local dota2_update_cmd="+app_update ${DOTA2_APPID:?}"
  local proton_update_cmd="+app_update ${PROTON_APPID:?}"

  if [[ -n "$STEAM_PASSWORD" ]]; then
    login_cmd+=" $STEAM_PASSWORD"
  fi

  if [[ "$STEAMCMD_VALIDATE" == "1" ]]; then
    dota2_update_cmd+=" -validate"
    proton_update_cmd+=" -validate"
  fi

  args=(
    "+@ShutdownOnFailedCommand 1"
    "$login_cmd"
    "+@sSteamCmdForcePlatformType ${STEAM_PLATFORM_WINDOWS:?}"
    "+app_set_config ${DOTA2_APPID:?} optionaldlc ${DOTA2_TOOLS_APPID:?}"
    "$dota2_update_cmd"
    "+@sSteamCmdForcePlatformType ${STEAM_PLATFORM_LINUX:?}"
    "$proton_update_cmd"
    '+@sSteamCmdForcePlatformType ""'
  )

  echo "Updating..."

  "${STEAMCMD:?}" "${args[@]}" "+quit"
}

[[ "$STEAMCMD_UPDATE" == "1" ]] && run_steamcmd

case "$1" in
d2tp)
  shift
  exec "${D2TP_RUN:?}" "$@"
  ;;
shell)
  shift
  exec "/bin/bash" -i -l "$@"
  ;;
*)
  exec "$@"
  ;;
esac
