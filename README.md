# dev-container

This is a docker image that imports a base image and adds dev-container functionalities for ssh'ing into the container.

Docker ontainers are available on dockerhub: [simonlenau/dev-container](https://hub.docker.com/r/simonlenau/dev-container)


## SSH keys

The ssh keys for host & user are defined in [`scripts/ssh_keys/`](scripts/ssh_keys).
$${\color{red}**Please change these keys** before using the container, as the default keys are **publicly available on [github](https://github.com/simon-lenau/dev-container/tree/main/scripts/ssh_keys)**$$