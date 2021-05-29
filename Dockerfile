### installer

FROM cm2network/steamcmd:root as installer

### final image

FROM d2tp:latest

ARG UID="1000"
ARG USER="steam"
ARG GID="1000"
ARG GROUP="steam"
ARG SHELL="/bin/bash"

ENV \
  # Dota 2
  DOTA2_APPID="570" \
  # Dota 2 Workshop Tools DLC
  DOTA2_TOOLS_APPID="313250" \
  # Proton 6.3
  PROTON_VERSION="6.3" \
  PROTON_APPID="1580130"

ENV \
  XDG_RUNTIME_DIR="/run/user/${UID}"

ENV \
  STEAMCMD_DIR="/home/${USER}/steamcmd" \
  STEAM_DIR="/home/${USER}/Steam" \
  D2TP_RUN="/home/${USER}/.local/bin/d2tp-run"

ENV \
  DOTA2_PATH="${STEAM_DIR}/steamapps/common/dota 2 beta" \
  PROTON_PATH="${STEAM_DIR}/steamapps/common/Proton ${PROTON_VERSION}"

RUN set -eux ; \
  groupadd -g "$GID" "$GROUP" ; \
  useradd -m -g "$GROUP" -u "$UID" -s "$SHELL" -d "/home/${USER}" "$USER" ; \
  mkdir -p "/run/user/$UID" ; \
  chown "${UID}:${GID}" "/run/user/$UID" ; \
  chmod 700 "/run/user/$UID" ; \
  dpkg --add-architecture i386 ; \
  apt-get update ; \
  apt-get -y install --no-install-recommends --no-install-suggests \
  dxvk dxvk:i386 \
  fontconfig \
  lib32gcc1 \
  lib32stdc++6 \
  libegl1 libegl1:i386 \
  libegl1-mesa libegl1-mesa:i386 \
  libfreetype6 libfreetype6:i386 \
  libgl1 libgl1:i386 \
  libgl1-mesa-dri libgl1-mesa-dri:i386 \
  libgl1-mesa-glx libgl1-mesa-glx:i386 \
  libglapi-mesa libglapi-mesa:i386 \
  libgles2 libgles2:i386 \
  libgles2-mesa libgles2-mesa:i386 \
  libglu1-mesa libglu1-mesa:i386 \
  libglvnd0 libglvnd0:i386 \
  libglw1-mesa libglw1-mesa:i386 \
  libglx0 libglx0:i386 \
  libvkd3d1 libvkd3d1:i386 \
  libvulkan1 libvulkan1:i386 \
  libxkbcommon0 libxkbcommon0:i386 \
  libxrandr2 libxrandr2:i386 \
  llvm-7 \
  locales \
  mesa-vulkan-drivers mesa-vulkan-drivers:i386 \
  vulkan-tools \
  vulkan-validationlayers vulkan-validationlayers:i386 \
  ; \
  echo "en_US.UTF-8 UTF-8" >> "/etc/locale.gen" ; \
  locale-gen ; \
  rm -rf /var/lib/apt/lists/*

ENV LANG="en_US.UTF-8" \
  LC_ALL="en_US.UTF-8"

COPY "data/glvnd/nvidia.json" "/usr/share/glvnd/egl_vendor.d/10_nvidia.json"
COPY "data/vulkan/nvidia_icd.json" "/usr/share/vulkan/icd.d/nvidia_icd.json"

COPY --from=installer --chown="${USER}:${GROUP}" "/home/steam/.steam" "/home/${USER}/.steam"
COPY --from=installer --chown="${USER}:${GROUP}" "/home/steam/Steam" "$STEAM_DIR"
COPY --from=installer --chown="${USER}:${GROUP}" "/home/steam/steamcmd" "$STEAMCMD_DIR"

RUN set -eux ; \
  ln -s "${STEAMCMD_DIR}/linux64/steamclient.so" "/usr/lib/x86_64-linux-gnu/steamclient.so"

COPY "data/docker-entrypoint.sh" "/usr/bin/docker-entrypoint.sh"
COPY --chown="${USER}:${GROUP}" "data/d2tp-run.sh" "$D2TP_RUN"

RUN set -eux ; \
  chmod a+x "/usr/bin/docker-entrypoint.sh" "$D2TP_RUN"

VOLUME "$STEAM_DIR"
VOLUME "$STEAMCMD_DIR"

USER "$USER"
WORKDIR "/home/${USER}"
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["shell"]
