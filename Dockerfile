# =========================== > Base environment < =========================== #

ARG FROM_IMAGE="projects.cispa.saarland:5005/c01sile/containr:latest"


FROM "$FROM_IMAGE"

ARG r_packages="" \
    python_packages="" \
    ubuntu_packages="" \
    workdir="/WORKDIR/" \
    outdir="/OUTDIR/"

ENV \
    DEV_CONTAINER_DIR="/dev-container" \
    WORKDIR="$workdir" \
    OUTDIR="$outdir"

ONBUILD ARG \
    r_packages="" \
    python_packages="" \
    ubuntu_packages="" \
    workdir="/WORKDIR/" \
    outdir="/OUTDIR/"

ONBUILD ENV \
    WORKDIR="$workdir" \
    OUTDIR="$outdir"

SHELL ["/bin/bash", "-c"]

# ────────────────────────────────── <end> ─────────────────────────────────── #

# ============================ > Copy ./scripts < ============================ #
COPY scripts/ /$DEV_CONTAINER_DIR/
RUN rm -rf /$DEV_CONTAINER_DIR/host
# ────────────────────────────────── <end> ─────────────────────────────────── #


# ========================== > Run Build scripts < =========================== #

# ========================= > Install dependencies < ========================= #

RUN \
    if [ -n "${ubuntu_packages}" ]; then \
        /$DEV_CONTAINER_DIR/build/install_ubuntu_pkgs "${ubuntu_packages}"; \
    fi; \
    if [ -n "${r_packages}" ]; then \ 
        /$DEV_CONTAINER_DIR/build/install_R_pkgs "${r_packages}"; \
    fi; \
    if [ -n "${python_packages}" ]; then \ 
        /$DEV_CONTAINER_DIR/build/install_python_pkgs "${python_packages}"; \
    fi;


ONBUILD RUN \
    if [ -n "${ubuntu_packages}" ]; then \
        /$DEV_CONTAINER_DIR/build/install_ubuntu_pkgs "${ubuntu_packages}"; \
    fi; \
    if [ -n "${r_packages}" ]; then \ 
        /$DEV_CONTAINER_DIR/build/install_R_pkgs "${r_packages}"; \
    fi; \
    if [ -n "${python_packages}" ]; then \ 
        /$DEV_CONTAINER_DIR/build/install_python_pkgs "${python_packages}"; \
    fi;


# ────────────────────────────────── <end> ─────────────────────────────────── #

# ======================== > Install vscode-server < ========================= #



RUN \
    vscode_init_file="/$DEV_CONTAINER_DIR/run/vscode-server_init"; \
    /$DEV_CONTAINER_DIR/build/install_vscode-server "linux" "x64" && \
    printf "%s\n" \
        "#!/usr/bin/env bash" \
        "ln -s "$HOME/.vscode-server/" ~/.vscode-server" \
        "ln -s "$HOME/code" ~/code/" \
        "ln -s "$HOME/.vscode" ~/.vscode/" \
        "ln -s "$HOME/code-server" ~/code-server/" \
        >> ${vscode_init_file} && \
        chmod a+x ${vscode_init_file}; \
        cat /$DEV_CONTAINER_DIR/run/vscode-server_init
# ────────────────────────────────── <end> ─────────────────────────────────── #

# ────────────────────────────────── <end> ─────────────────────────────────── #



# =============================== > SSH keys < =============================== #
COPY scripts/ssh_keys/* /$DEV_CONTAINER_DIR/ssh_keys/
COPY scripts/ssh_keys/* /$DEV_CONTAINER_DIR/run/.default_ssh_keys/
# ────────────────────────────────── <end> ─────────────────────────────────── #

RUN ln -s "${DEV_CONTAINER_DIR}/run/dropbear_init" /dropbear_init
RUN ln -s "${DEV_CONTAINER_DIR}/run/entrypoint_ssh" /.entrypoint_ssh

CMD bash -c "/dropbear_init"
