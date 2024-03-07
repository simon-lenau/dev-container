#!/bin/bash
source .env.host

mkdir -p ${output_path}

srun \
    --job-name="${BASH_SOURCE[0]}${ZSH_ARGZERO} -- ${now}" \
    --cpus-per-task=255 \
    --time 150:00 \
    --mail-type=ALL \
    --mail-user=lenau@cispa.de \
    --partition=r65257773x \
    --container-image=${gitlab_registry}dev-container:latest \
    --no-container-mount-home \
    --container-entrypoint \
    --pty bash
# --output="${output_path}/Job_%x_%j.log" \
# Rscript Example_Script.R
