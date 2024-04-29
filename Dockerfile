# =========================== > Base environment < =========================== #

ARG ubuntu_packages=""

FROM "rocker/r-ver:4.3.3"

ARG ubuntu_packages

SHELL ["/bin/bash", "-c"]

# ────────────────────────────────── <end> ─────────────────────────────────── #

# ========================== > Run Build scripts < =========================== #

COPY scripts/build /build_scripts

# ======================= > Install Ubuntu packages < ======================== #

RUN if [ -n "${ubuntu_packages}" ]; then \
    /build_scripts/install_pkgs "${ubuntu_packages}"; \
    fi; 

# ======================== > Install vscode-server < ========================= #

RUN chmod u+rwx /build_scripts/install_vscode-server && \
    /build_scripts/install_vscode-server "linux" "x64"

# ────────────────────────────────── <end> ─────────────────────────────────── #

RUN rm -rf /build_scripts

# ────────────────────────────────── <end> ─────────────────────────────────── #
# ────────────────────────────────── <end> ─────────────────────────────────── #

# ========================= > Copy Runtime Scripts < ========================= #
COPY scripts /run/scripts
# ────────────────────────────────── <end> ─────────────────────────────────── #


# ============================ > Setup Dropbear < ============================ #
COPY /ssh_keys/* /etc/dropbear/
# ────────────────────────────────── <end> ─────────────────────────────────── #



CMD ["/bin/bash"]
