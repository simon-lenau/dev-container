#!/bin/bash

source "submodules/gitlab_tokens/init"

source scripts/host/gitlab_tokens

printf "export %s\n" "WORKDIR=/EXAMPLE/" "OUTDIR=/EXAMPLE_OUTPUT/" > ./.env


srun \
    --job-name="${BASH_SOURCE[0]}${ZSH_ARGZERO} -- ${now}" \
    --cpus-per-task=5 \
    --time 300:00 \
    --mail-type=ALL \
    --mail-user=lenau@cispa.de \
    --partition=r65257773x \
    --container-image=$(git_repo_info --type="registry")dev-container:latest \
    --no-container-mount-home \
    --container-mounts="./.env:/.env" \
    --container-entrypoint \
    bash -c "/\$DEV_CONTAINER_DIR/dropbear_init"
