# =========================== > Base environment < =========================== #

ARG FROM_IMAGE="projects.cispa.saarland:5005/c01sile/containr/r-ver:latest"


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

# ========================== > Run Build scripts < =========================== #

COPY scripts/build /$DEV_CONTAINER_DIR/build

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

# ========================= > Copy Runtime Scripts < ========================= #
COPY scripts/run $DEV_CONTAINER_DIR/run
# ────────────────────────────────── <end> ─────────────────────────────────── #

# ======================== > Install vscode-server < ========================= #
RUN \
    touch /$DEV_CONTAINER_DIR/run/vscode-server_init && \
    chmod a+x /$DEV_CONTAINER_DIR/run/vscode-server_init \
    cat >> /$DEV_CONTAINER_DIR/run/vscode-server_init <<'EOF'
#!/usr/bin/env bash
ln -s "$HOME/.vscode-server/" ~/.vscode-server/
ln -s "$HOME/code" ~/code/
ln -s "$HOME/.vscode" ~/.vscode/
ln -s "$HOME/code-server" ~/code-server/
EOF
    
RUN cat /$DEV_CONTAINER_DIR/run/vscode-server_init
# ────────────────────────────────── <end> ─────────────────────────────────── #

# ────────────────────────────────── <end> ─────────────────────────────────── #



# =============================== > SSH keys < =============================== #
COPY scripts/ssh_keys/* /$DEV_CONTAINER_DIR/ssh_keys/
COPY scripts/ssh_keys/* /$DEV_CONTAINER_DIR/run/.default_ssh_keys/
# ────────────────────────────────── <end> ─────────────────────────────────── #

RUN ln -s "${DEV_CONTAINER_DIR}/run/dropbear_init" /dropbear_init
RUN ln -s "${DEV_CONTAINER_DIR}/run/entrypoint_ssh" /.entrypoint_ssh

CMD bash -c "/dropbear_init"
