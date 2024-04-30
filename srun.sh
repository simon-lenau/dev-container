#!bash

source "submodules/gitlab_tokens/init"

echo "Hardcoded test path in git_token_valid_enroot"

source scripts/host/gitlab_tokens

srun \
    --job-name="${BASH_SOURCE[0]}${ZSH_ARGZERO} -- ${now}" \
    --cpus-per-task=5 \
    --time 300:00 \
    --mail-type=ALL \
    --mail-user=lenau@cispa.de \
    --partition=r65257773x \
    --container-image=projects.cispa.saarland:5005#c01sile/dev-container/dev-container:latest \
    --no-container-mount-home \
    --container-entrypoint \
    --pty bash
