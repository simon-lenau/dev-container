source ./.env

ssh \
    -i ./scripts/ssh_keys/dev-container_user_id \
    -p ${dropbear_port} \
    -l root \
    127.0.0.1