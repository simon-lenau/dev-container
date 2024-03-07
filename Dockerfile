# =========================== > Base environment < =========================== #

ARG ubuntu_packages=""

FROM "r-base:latest"

ARG ubuntu_packages

SHELL ["/bin/bash", "-c"]

COPY install_pkgs /install_pkgs

RUN echo "ubuntu_packages:" && printf "%s\n" "${ubuntu_packages}"

RUN if [ -n "${ubuntu_packages}" ]; then \
    /install_pkgs "${ubuntu_packages}"; \
    fi; 

CMD ["/bin/bash"]

# ────────────────────────────────── <end> ─────────────────────────────────── #
