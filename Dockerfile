# =========================== > Base environment < =========================== #

ARG r_packages=""
ARG ubuntu_packages=""
ARG FROM_IMAGE="projects.cispa.saarland:5005/c01sile/containr/r-ver:latest"


FROM "$FROM_IMAGE"

ARG r_packages
ARG ubuntu_packages

SHELL ["/bin/bash", "-c"]

# ────────────────────────────────── <end> ─────────────────────────────────── #

# ========================== > Run Build scripts < =========================== #

COPY scripts/build /dev-container_build_scripts

# ========================= > Package installation < ========================= #

# =========================== > Ubuntu packages < ============================ #
RUN if [ -n "${ubuntu_packages}" ]; then \
    /dev-container_build_scripts/install_ubuntu_pkgs "${ubuntu_packages}"; \
    fi; 
# ────────────────────────────────── <end> ─────────────────────────────────── #


# ────────────────────────────────── <end> ─────────────────────────────────── #


# ======================== > Install vscode-server < ========================= #
# 2024-04-29: Currently not working
RUN chmod u+rwx /dev-container_build_scripts/install_vscode-server && \
    /dev-container_build_scripts/install_vscode-server "linux" "x64"
# ────────────────────────────────── <end> ─────────────────────────────────── #

RUN rm -rf /dev-container_build_scripts

# ────────────────────────────────── <end> ─────────────────────────────────── #

# ========================= > Copy Runtime Scripts < ========================= #
COPY scripts/run /dev-container_scripts
# ────────────────────────────────── <end> ─────────────────────────────────── #


# ============================ > Dropbear setup < ============================ #
COPY ssh_keys/* /etc/dropbear/
# ────────────────────────────────── <end> ─────────────────────────────────── #

CMD ["/bin/bash"]
