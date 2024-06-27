# dev-container

This is a docker image that imports a base image and adds dev-container functionalities for [SSH](https://en.wikipedia.org/wiki/Secure_Shell)'ing into the container and
setting up the working environment once the connection is established.

Docker ontainers are available on dockerhub: [simonlenau/dev-container](https://hub.docker.com/r/simonlenau/dev-container)

## SSH connection

### SSH server

To allow a connection inside the container, a [SSH](https://en.wikipedia.org/wiki/Secure_Shell) server is started
using [Dropbear](https://github.com/mkj/dropbear). \
The server is started running the [`/dropbear_init`](scripts/run/dropbear_init) script


### SSH keys

Some default [SSH](https://en.wikipedia.org/wiki/Secure_Shell) keys for host & user are stored in [`scripts/ssh_keys/`](scripts/ssh_keys). \
The default keys are **publicly available on [github](https://github.com/simon-lenau/dev-container/tree/main/scripts/ssh_keys)**
```diff
!!! Please replace these keys before using the container !!!
```


#### Replacing default SSH keys

The default SSH keys can be replaced 
by

1. mounting a folder to `/dev-container/ssh_keys`
    with files corresponding to those in [`scripts/ssh_keys/`](scripts/ssh_keys) and/or
2. running [`/dev-container/run/ssh_key_setup "generate"`](scripts/run/ssh_key_setup) inside the container

When combining **1.** and **2.**, the keys will be (re)placed the in mounted folder and easily re-usable.


### Connecting to the SSH server

To connect to the [SSH](https://en.wikipedia.org/wiki/Secure_Shell) server inside the container,
tools like [OpenSSH](https://www.openssh.com/) or [Dropbear](https://github.com/mkj/dropbear)
may be used.

## Working environment set-up

The working environment is defined by two folders defined in environment variables
`${WORKDIR}` and `${OUTDIR}`.

Once a client connects into the container using [SSH](https://en.wikipedia.org/wiki/Secure_Shell),
[`scripts/run/ssh_entrypoint`](scripts/run/ssh_shell_setup) is `source`ed.
It executes the following steps:

1. If an environment file `~/.env` or `/.env` exists, source it.
2. If an entrypoint script `/.entrypoint` exists, source it
3. If user does not object: open `${WORKDIR}` in [vscode](https://code.visualstudio.com/) and/or terminal

