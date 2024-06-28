#!/usr/bin/env bash
docker_image="simonlenau/dev-container:containr_latest"

printf "export %s\n" \
    "WORKDIR=~/EXAMPLE/" \
    "OUTDIR=~/EXAMPLE_OUTPUT/" \
    "dropbear_port=$(id -u)" \
    >./.env


if [[ "${HOST}${HOSTNAME}" =~ "MacBook" ]]; then
    {
        docker_path="$(
            printf -- "$(git_repo_info --type="registry")" |
                perl -p0e "s/(5005)#/\${1}\//gmi"
        )"

        echo "${GITLAB_ACCESS_TOKEN}" |
            docker login \
                --username c01sile \
                --password-stdin \
                "${docker_path}" \
                > \
                /dev/null
    }
    docker pull ${docker_path}r-ver:latest
    docker run \
        --mount type=bind,source=./.env,destination=/.env,readonly \
        --mount type=bind,source=./scripts/run/,destination=/dev-container/run \
        -p 127.0.0.1:11782:11782/tcp \
        -t -i \
        ${docker_path}r-ver:latest \
        bash -c /\$DEV_CONTAINER_DIR/run/dropbear_init
else
    srun \
        --job-name="${BASH_SOURCE[0]}${ZSH_ARGZERO} -- $(date -Iminutes)" \
        --cpus-per-task=5 \
        --time 300:00 \
        --mail-type=ALL \
        --mail-user=lenau@cispa.de \
        --partition=r65257773x \
        --container-image="${docker_image}" \
        --no-container-mount-home \
        --container-mounts="./.env:/.env,./ssh_keys/:/dev-container/ssh_keys/,./scripts/run/:/dev-container/run " \
        --container-entrypoint \
        --pty bash -c /\$DEV_CONTAINER_DIR/run/dropbear_init
fi

