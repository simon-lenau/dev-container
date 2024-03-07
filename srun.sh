#!/bin/bash
source .env.host

# rm -rf ./dev-container*

# echo "" | ssh-keygen -f ./dev-container

exit 0
srun \
    --job-name="${BASH_SOURCE[0]}${ZSH_ARGZERO} -- ${now}" \
    --cpus-per-task=255 \
    --time 150:00 \
    --mail-type=ALL \
    --mail-user=lenau@cispa.de \
    --partition=r65257773x \
    --container-image=${gitlab_registry}dev-container:latest \
    --container-mounts="./dev-container.pub:~/.ssh/authorized_keys:ro,./dropbear_init:/dropbear_init:ro" \
    --no-container-mount-home \
    --container-entrypoint \
    --pty bash
# --output="${output_path}/Job_%x_%j.log" \
# Rscript Example_Script.R
