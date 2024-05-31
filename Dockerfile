# =========================== > Base environment < =========================== #

ARG FROM_IMAGE="projects.cispa.saarland:5005/c01sile/containr/r-ver:latest"


FROM "$FROM_IMAGE"

ARG r_packages="" \
    ubuntu_packages="" \
    workdir="/WORKDIR/" \
    outdir="/OUTDIR/"

ENV \
    DEV_CONTAINER_DIR="/dev-container" \
    WORKDIR="$workdir" \
    OUTDIR="$outdir"

ONBUILD ENV DEV_CONTAINER_DIR="$DEV_CONTAINER_DIR"

SHELL ["/bin/bash", "-c"]

# ────────────────────────────────── <end> ─────────────────────────────────── #

# ========================== > Run Build scripts < =========================== #

COPY scripts/build /$DEV_CONTAINER_DIR/build

# ========================= > Install dependencies < ========================= #

RUN \
    if [ -n "${ubuntu_packages}" ]; then \
        /$DEV_CONTAINER_DIR/build/install_ubuntu_pkgs "${ubuntu_packages}"; \
    fi; \
    if [ -n "${r_packages}" ]; then \ 
        /$DEV_CONTAINER_DIR/build/install_R_pkgs "${r_packages}"; \
    fi


ONBUILD RUN \
    if [ -n "${ubuntu_packages}" ]; then \
        /$DEV_CONTAINER_DIR/build/install_ubuntu_pkgs "${ubuntu_packages}"; \
    fi; \
    if [ -n "${r_packages}" ]; then \ 
        /$DEV_CONTAINER_DIR/build/install_R_pkgs "${r_packages}"; \
    fi


# ────────────────────────────────── <end> ─────────────────────────────────── #


# ======================== > Install vscode-server < ========================= #
# 2024-05-15: Currently not working
# RUN chmod u+rwx /$DEV_CONTAINER_DIR/build/install_vscode-server && \
#     /$DEV_CONTAINER_DIR/build/install_vscode-server "linux" "x64"
# ────────────────────────────────── <end> ─────────────────────────────────── #

# ────────────────────────────────── <end> ─────────────────────────────────── #

# ========================= > Copy Runtime Scripts < ========================= #
COPY scripts/run /$DEV_CONTAINER_DIR/run
# ────────────────────────────────── <end> ─────────────────────────────────── #

# =============================== > SSH keys < =============================== #
COPY scripts/ssh_keys/* /$DEV_CONTAINER_DIR/ssh_keys/
COPY scripts/ssh_keys/* /$DEV_CONTAINER_DIR/run/.default_ssh_keys/
# ────────────────────────────────── <end> ─────────────────────────────────── #

RUN ln -s "${DEV_CONTAINER_DIR}/run/dropbear_init" /dropbear_init

CMD bash -c "/dropbear_init"
