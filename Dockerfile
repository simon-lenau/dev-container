# =========================== > Base environment < =========================== #

ARG FROM_IMAGE="projects.cispa.saarland:5005/c01sile/containr/r-ver:lates"


FROM "$FROM_IMAGE"

ARG r_packages="" \
    ubuntu_packages="" \
    workdir="/WORKDIR/" \
    outdir="/OUTDIR/"

ENV \
    DEV_CONTAINER_DIR="/dev-container_scripts" \
    WORKDIR="$workdir" \
    OUTDIR="$outdir"

SHELL ["/bin/bash", "-c"]

# ────────────────────────────────── <end> ─────────────────────────────────── #

# ========================== > Run Build scripts < =========================== #

COPY scripts/build /$DEV_CONTAINER_DIR/build

# ========================= > Install dependencies < ========================= #

RUN if [ -n "${ubuntu_packages}" ]; then \
    /$DEV_CONTAINER_DIR/build/install_ubuntu_pkgs "${ubuntu_packages}"; \
    fi; \
    \
    if [ -n "${r_packages}" ]; then \ 
    /$DEV_CONTAINER_DIR/build/install_R_pkgs "${r_packages}"; \
    fi


ONBUILD RUN if [ -n "${ubuntu_packages}" ]; then \
    /$DEV_CONTAINER_DIR/build/install_ubuntu_pkgs "${ubuntu_packages}"; \
    fi; \
    \
    if [ -n "${r_packages}" ]; then \ 
    /$DEV_CONTAINER_DIR/build/install_R_pkgs "${r_packages}"; \
    fi


# ────────────────────────────────── <end> ─────────────────────────────────── #


# ======================== > Install vscode-server < ========================= #
# 2024-04-29: Currently not working
# RUN chmod u+rwx /$DEV_CONTAINER_DIR/build/install_vscode-server && \
#     /$DEV_CONTAINER_DIR/build/install_vscode-server "linux" "x64"
# ────────────────────────────────── <end> ─────────────────────────────────── #

ONBUILD RUN rm -rf /$DEV_CONTAINER_DIR/build

# ────────────────────────────────── <end> ─────────────────────────────────── #

# ========================= > Copy Runtime Scripts < ========================= #
COPY scripts/run /$DEV_CONTAINER_DIR
# ────────────────────────────────── <end> ─────────────────────────────────── #


# ============================ > Dropbear setup < ============================ #
COPY ssh_keys/* /etc/dropbear/
# ────────────────────────────────── <end> ─────────────────────────────────── #

CMD bash -c "/\$DEV_CONTAINER_DIR/dropbear_init"
