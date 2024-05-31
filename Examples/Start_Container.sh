printf "export %s\n" \
    "WORKDIR=~/EXAMPLE/" \
    "OUTDIR=~/EXAMPLE_OUTPUT/" \
    "dropbear_port="$(echo "$(id -u)12345" | cut -c1-5)""  \
    >./.env

source ./.env

docker pull simonlenau/dev-container:containr_latest

docker run \
    --mount type=bind,source=./.env,destination=/.env,readonly \
    -p 127.0.0.1:${dropbear_port}:${dropbear_port}/tcp \
    -t -i \
    simonlenau/dev-container:containr_latest \
    bash -c /dropbear_init

