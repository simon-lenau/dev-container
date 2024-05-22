#!/usr/bin/env bash
source "submodules/gitlab-tokens/gitlab-tokens-init"

source "scripts/host/manage-gitlab-token"

printf "export %s\n" "WORKDIR=~/EXAMPLE/" "OUTDIR=~/EXAMPLE_OUTPUT/" >./.env

if [[ "${HOST}${HOSTNAME}" =~ "MacBook" ]]; then
    {
        docker_path="$(
            printf -- "$(git_repo_info --type="registry")" |
            perl -p0e "s/(5005)#/\${1}\//gmi" 
        )"

        echo "${CISPA_GITLAB_TOKEN}" |
            docker login \
                --username c01sile \
                --password-stdin \
                "${docker_path}" \
                > \
                /dev/null
    }
    docker pull ${docker_path}dev-container:latest
    docker run \
        --mount type=bind,source=./.env,destination=/.env,readonly \
        -p 127.0.0.1:11782:11782/tcp \
        -t -i \
        ${docker_path}r-ver:latest \
        bash -c /\$DEV_CONTAINER_DIR/run/dropbear_init
else
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
        bash -c /\$DEV_CONTAINER_DIR/run/dropbear_init
fi
