# =========================== > Base environment < =========================== #

ARG ubuntu_packages=""

FROM "rocker/r-ver:4.3.3"

ARG ubuntu_packages

SHELL ["/bin/bash", "-c"]

COPY install_pkgs /install_pkgs

RUN if [ -n "${ubuntu_packages}" ]; then \
    /install_pkgs "${ubuntu_packages}"; \
    fi; 

CMD ["/bin/bash"]

# ────────────────────────────────── <end> ─────────────────────────────────── #
