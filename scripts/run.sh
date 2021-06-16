#!/bin/bash

set -e

CUSTOM_GAME_PATH="/home/steam/custom_game"

image="dota2tools"
# shellcheck disable=2153
steam_user="$STEAM_USER"
# shellcheck disable=2153
steam_password="$STEAM_PASSWORD"
# shellcheck disable=2153
steamcmd_update="$STEAMCMD_UPDATE"
# shellcheck disable=2153
steamcmd_validate="$STEAMCMD_VALIDATE"
custom_game=""

declare -A volume_paths=(
  ["steam"]="/home/steam/Steam"
  ["steamcmd"]="/home/steam/steamcmd"
)

declare -A volume_names=(
  ["steam"]="dota2tools-steam"
  ["steamcmd"]="dota2tools-steamcmd"
)

while getopts "i:v:e:u:p:UVc:h" opt; do
  case "$opt" in
  i)
    image="$OPTARG"
    ;;
  v)
    ventry="$(echo "$OPTARG" | cut -d':' -f1)"
    vname="$(echo "$OPTARG" | cut -d':' -f2)"

    if [[ -z "${volume_paths["$ventry"]}" ]]; then
      echo >&2 "Invalid volume entry $ventry"
      exit 1
    fi

    volume_names["$ventry"]="$vname"
    ;;
  e)
    env_file="$OPTARG"
    ;;
  u)
    steam_user="$OPTARG"
    ;;
  p)
    steam_password="$OPTARG"
    ;;
  U)
    steamcmd_update=1
    ;;
  V)
    steamcmd_update=1
    steamcmd_validate=1
    ;;
  c)
    custom_game="$OPTARG"
    ;;
  ?)
    cat >&2 <<EOF
Usage: $0 [options] [<entrypoint_cmd> [entrypoint_args...]]

Options:
  -i <image>       Image name [default: ${image}]
  -v <entry:name>  Sets volume name for given volume entry [defaults: steam:${volume_names["steam"]}, steamcmd:${volume_names["steamcmd"]}]
  -e <env_file>    Env file containing environment variables
  -u <username>    Steam username (environment: STEAM_USER)
  -p <password>    Steam password (environment: STEAM_PASSWORD)
  -U               Update game files (environment: STEAMCMD_UPDATE)
  -V               Validate game files (environment: STEAMCMD_VALIDATE)
  -c               Path to a custom game to be mounted at "${CUSTOM_GAME_PATH}"
EOF
    exit 2
    ;;
  esac
done

shift $((OPTIND - 1))

options=(
  "--interactive" "--tty" "--rm"
  "--runtime" "nvidia"
  "--gpus" "all"
  "--env" "NVIDIA_DRIVER_CAPABILITIES=all"
  "--env" "DISPLAY=$DISPLAY"
  "--env" "STEAMCMD_UPDATE=$steamcmd_update"
  "--env" "STEAMCMD_VALIDATE=$steamcmd_validate"
  "--volume" "/tmp/.X11-unix:/tmp/.X11-unix"
)

if [[ -n "$env_file" ]]; then
  options+=("--env-file" "$env_file")
fi

if [[ -n "$steam_user" ]]; then
  options+=("--env" "STEAM_USER=$steam_user")
fi

if [[ -n "$steam_password" ]]; then
  options+=("--env" "STEAM_PASSWORD=$steam_password")
fi

for volume in "${!volume_names[@]}"; do
  options+=("--volume" "${volume_names["$volume"]}:${volume_paths["$volume"]}")
done

if [[ -n "$custom_game" ]]; then
  options+=("--volume" "${custom_game}:${CUSTOM_GAME_PATH}")
fi

exec docker run "${options[@]}" -- "$image" "$@"
