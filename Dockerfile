# =========================== > Base environment < =========================== #

ARG ubuntu_packages=""

FROM "rocker/r-ver:4.3.3"

ARG ubuntu_packages

SHELL ["/bin/bash", "-c"]

COPY install_pkgs /install_pkgs
COPY download-vs-code-server.sh /download-vs-code-server.sh

RUN if [ -n "${ubuntu_packages}" ]; then \
    /install_pkgs "${ubuntu_packages}"; \
    fi; 

RUN chmod u+rwx /download-vs-code-server.sh && \
    /download-vs-code-server.sh "linux" "x64"

CMD ["/bin/bash"]

# ────────────────────────────────── <end> ─────────────────────────────────── #
