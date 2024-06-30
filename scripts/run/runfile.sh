#!/usr/bin/env bash

bashrc_path="$(dirname "${BASH_SOURCE[0]}")/Testfile"

begin_delim="# >>>>>>>>>>>>>>>>>>>> dev-container shell setup >>>>>>>>>>>>>>>>>>>> "
end_delim="# <<<<<<<<<<<<<<<<<<<< dev-container shell setup <<<<<<<<<<<<<<<<<<<< "



if grep -iq "${begin_delim}" "${bashrc_path}"; then
    perl -p0i -e "s/${begin_delim}.*${end_delim}//gms" "${bashrc_path}"
fi

    cat \
        >>${bashrc_path} <<EOF
${begin_delim}
export DEV_CONTAINER_DIR="${DEV_CONTAINER_DIR}"
export PATH="${PATH}:\${PATH}"
if [[ "\${TERM_PROGRAM}" == "vscode" ]]; then
    export __ssh_entrypoint_run__=
fi
export __SET_FOLDER__=${__SET_FOLDER__}
source /.ssh_entrypoint
${end_delim}
EOF
