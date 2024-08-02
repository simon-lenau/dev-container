# =========================== > Base environment < =========================== #

ARG FROM_IMAGE="projects.cispa.saarland:5005/c01sile/containr:latest"

FROM "$FROM_IMAGE"

ARG r_packages="" \
    python_packages="" \
    ubuntu_packages="" \
    vscode_extensions="" \
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
    vscode_extensions="" \
    workdir="/WORKDIR/" \
    outdir="/OUTDIR/"

ONBUILD ENV \
    WORKDIR="$workdir" \
    OUTDIR="$outdir"

SHELL ["/bin/bash", "-c"]

# ────────────────────────────────── <end> ─────────────────────────────────── #

# ============================ > Copy ./scripts < ============================ #
COPY scripts/run /$DEV_CONTAINER_DIR/run
COPY scripts/build /$DEV_CONTAINER_DIR/build
# ────────────────────────────────── <end> ─────────────────────────────────── #

# ========================== > Run Build scripts < =========================== #

# ========================= > Install dependencies < ========================= #

RUN \
    if [ -n "${ubuntu_packages}" ]; then \
        /$DEV_CONTAINER_DIR/build/install_ubuntu_pkgs "${ubuntu_packages}"  || exit $?;  \    
    fi;
ONBUILD RUN \
    if [ -n "${ubuntu_packages}" ]; then \
        /$DEV_CONTAINER_DIR/build/install_ubuntu_pkgs "${ubuntu_packages}"  || exit $?;  \
    fi;


RUN \
    if [ -n "${r_packages}" ]; then \ 
        /$DEV_CONTAINER_DIR/build/install_R_pkgs "${r_packages}" || exit $?;  \
    fi;
ONBUILD RUN \
    if [ -n "${r_packages}" ]; then \ 
        /$DEV_CONTAINER_DIR/build/install_R_pkgs "${r_packages}"  || exit $?;  \
    fi;

RUN \
    if [ -n "${python_packages}" ]; then \ 
        /$DEV_CONTAINER_DIR/build/install_python_pkgs "${python_packages}" || exit $?; \
    fi;
ONBUILD RUN \
    if [ -n "${python_packages}" ]; then \ 
        /$DEV_CONTAINER_DIR/build/install_python_pkgs "${python_packages}" || exit $?;  \
    fi;

# ────────────────────────────────── <end> ─────────────────────────────────── #

# ======================== > Install vscode-server < ========================= #
RUN \
    /$DEV_CONTAINER_DIR/build/install_vscode-server "linux" "x64"

RUN \
    export PATH="/root/.vscode-server/bin/default_version/bin:$PATH"; \
    if [ -n "${vscode_extensions}" ]; then \
        /$DEV_CONTAINER_DIR/build/install_vscode-extensions "${vscode_extensions}"  || exit $?;  \    
    fi;

ONBUILD RUN \
    export PATH="/root/.vscode-server/bin/default_version/bin:$PATH"; \
    if [ -n "${vscode_extensions}" ]; then \
        /$DEV_CONTAINER_DIR/build/install_vscode-extensions "${vscode_extensions}"  || exit $?;  \    
    fi;
# ────────────────────────────────── <end> ─────────────────────────────────── #

# ────────────────────────────────── <end> ─────────────────────────────────── #

# =============================== > SSH keys < =============================== #
COPY scripts/ssh_keys/* /$DEV_CONTAINER_DIR/ssh_keys/
COPY scripts/ssh_keys/* /$DEV_CONTAINER_DIR/run/.default_ssh_keys/
# ────────────────────────────────── <end> ─────────────────────────────────── #

RUN \
    chmod a+x "${DEV_CONTAINER_DIR}/run/dropbear_init"; \
    ln -s "${DEV_CONTAINER_DIR}/run/ssh_entrypoint" /.ssh_entrypoint; \
    ln -s "${DEV_CONTAINER_DIR}/run/dropbear_init" /dropbear_init;



CMD bash -c "/dropbear_init"
