# =========================== > Base environment < =========================== #

ARG FROM_IMAGE="projects.cispa.saarland:5005/c01sile/containr/r-ver:latest"


FROM "$FROM_IMAGE"

ARG r_packages="" \
    ubuntu_packages="" \
    workdir="/WORKDIR/" \
    outdir="/OUTDIR/"

ENV \
    DEV_CONTAINER_DIR="/dev-container_scripts" \
    WORKDIR="$workdir" \
    OUTDIR="$outdir"

ONBUILD ENV DEV_CONTAINER_DIR="$DEV_CONTAINER_DIR"

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
RUN curl -L \
    https://raw.githubusercontent.com/b01/dl-vscode-server/main/download-vs-code-server.sh | 
    bash -s -- "linux"

# ────────────────────────────────── <end> ─────────────────────────────────── #

ONBUILD RUN rm -rf /$DEV_CONTAINER_DIR/build

# ────────────────────────────────── <end> ─────────────────────────────────── #

# ========================= > Copy Runtime Scripts < ========================= #
COPY scripts/run /$DEV_CONTAINER_DIR
# ────────────────────────────────── <end> ─────────────────────────────────── #


# ============================ > Dropbear setup < ============================ #
COPY ssh_keys    /* /etc/dropbear/
# ────────────────────────────────── <end> ─────────────────────────────────── #





CMD bash -c "/\$DEV_CONTAINER_DIR/dropbear_init"
