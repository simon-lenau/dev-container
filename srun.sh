#!/bin/bash
source .env.host
chmod a+rwx dropbear_init

srun \
    --job-name="${BASH_SOURCE[0]}${ZSH_ARGZERO} -- ${now}" \
    --cpus-per-task=255 \
    --time 150:00 \
    --mail-type=ALL \
    --mail-user=lenau@cispa.de \
    --partition=r65257773x \
    --container-image=${git_registry}dev-container:latest \
    --container-mounts="./dev-container.pub:~/.ssh/authorized_keys:ro,./dropbear_init:/dropbear_init:ro" \
    --no-container-mount-home \
    --container-entrypoint \
    --pty bash
# --output="${output_path}/Job_%x_%j.log" \
# Rscript Example_Script.R
