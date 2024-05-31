printf "export %s\n" \
    "WORKDIR=~/EXAMPLE/" \
    "OUTDIR=~/EXAMPLE_OUTPUT/" \
    "dropbear_port="$(echo "$(id -u)12345" | cut -c1-5)""  \
    >./.env

source ./.env

# docker pull simonlenau/dev-container:containr_latest

# exit 0

docker run \
    --mount type=bind,source=./.env,destination=/.env,readonly \
    --mount type=bind,source=./scripts/run/ssh_key_check,destination=/dev-container/run/ssh_key_check \
    --mount type=bind,source=./scripts/run/print_functions,destination=/dev-container/run/print_functions \
    -p 127.0.0.1:${dropbear_port}:${dropbear_port}/tcp \
    -t -i \
    simonlenau/dev-container:containr_latest \
    bash #-c /dropbear_init
