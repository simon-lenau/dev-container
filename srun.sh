#!/bin/bash
# source .env.host
# chmod a+rwx dropbear_init

CISPA_GITLAB_TOKEN="$(cat /home/c01sile/credentials/projects.cispa.saarland)"

srun \
    --job-name="${BASH_SOURCE[0]}${ZSH_ARGZERO} -- ${now}" \
    --cpus-per-task=255 \
    --time 300:00 \
    --mail-type=ALL \
    --mail-user=lenau@cispa.de \
    --partition=r65257773x \
    --container-image=projects.cispa.saarland:5005#c01sile/dev-container/dev-container:latest \
    --container-mounts="./dev-container.pub:$HOME/.ssh/authorized_keys:ro" \
    --no-container-mount-home \
    --container-entrypoint \
    --pty bash
# --output="${output_path}/Job_%x_%j.log" \
# Rscript Example_Script.R
# rm /etc/dropbear/dropbear_ed25519_host_key
# dropbearkey -t ed25519 -f /etc/dropbear/dropbear_ed25519_host_key
# dropbear -F -E -p $(id -u)


# rm /etc/dropbear/dropbear_ecdsa_host_key
# dropbearkey -t ecdsa -f /etc/dropbear/dropbear_ecdsa_host_key
# dropbear -F -E -p $(id -u)


# rm /etc/dropbear/dropbear_rsa_host_key
# dropbearkey -t rsa -f /etc/dropbear/dropbear_rsa_host_key
# dropbear -F -E -p $(id -u)