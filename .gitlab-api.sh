#!/bin/bash

git_registry_port=5005
git_api_version=4
token_duration="1 day"

# ============================= > Dependencies < ============================= #

# List of required dependencies
dependencies=("jq")

# ┌┌────────────────────────────────────────────────────────────────────────┐┐ #
# ││ `check_dependency`                                                     ││ #
# ││                                                                        ││ #
# ││ check if a command is available                                        ││ #
# ││                                                                        ││ #
# ││ Input:                                                                 ││ #
# ││ $1 : command (string): The command to be checked                       ││ #
# ││                                                                        ││ #
# ││ Output:                                                                ││ #
# ││ 0 if successful, else 1                                                ││ #
# ││                                                                        ││ #
# ││ Usage:                                                                 ││ #
# ││ check_dependency <command>                                             ││ #
# ││                                                                        ││ #
# ││ Examples:                                                              ││ #
# ││ check_dependency "jq"                                                  ││ #
# └└────────────────────────────────────────────────────────────────────────┘┘ #
function check_dependency {
    local command="${1}"
    # Check if command can be run
    command -v "${command}" >/dev/null 2>&1 || {
        echo >&2 "${command} is required but not installed. Aborting."
        return 1
    }
}

# Check each dependency
for dep in "${dependencies[@]}"; do
    check_dependency "$dep"
done

# ────────────────────────────────── <end> ─────────────────────────────────── #

# =============================== > git_api < ================================ #
# ┌┌────────────────────────────────────────────────────────────────────────┐┐ #
# ││ `git_api`                                                              ││ #
# ││                                                                        ││ #
# ││ Function to access the current repo's gitlab API via curl              ││ #
# ││                                                                        ││ #
# ││ Output:                                                                ││ #
# ││ The result of the API call                                             ││ #
# ││                                                                        ││ #
# ││ Examples:                                                              ││ #
# ││ git_api                                                                ││ #
# └└────────────────────────────────────────────────────────────────────────┘┘ #
function git_api {
    curl \
        --silent \
        --header "PRIVATE-TOKEN: ${__gitlab_api_secret__}" \
        ${@}

}
# ────────────────────────────────── <end> ─────────────────────────────────── #

# ========================== > git_api_secret_set < ========================== #

# ┌┌────────────────────────────────────────────────────────────────────────┐┐ #
# ││ `git_api_secret_set`                                                   ││ #
# ││                                                                        ││ #
# ││ Check whether secret for gitlab API access is valid                    ││ #
# ││                                                                        ││ #
# ││ Input:                                                                 ││ #
# ││ $1 : api_secret (string): The credential (personal access token)       ││ #
# ││                                                                        ││ #
# ││ Output:                                                                ││ #
# ││ null                                                                   ││ #
# ││                                                                        ││ #
# ││ Usage:                                                                 ││ #
# ││ git_api_secret_set <api_credential>                                    ││ #
# ││                                                                        ││ #
# ││ Examples:                                                              ││ #
# ││ git_api_secret_set "glpat-aG2fJfixfGub6ULt2L5_"                        ││ #
# └└────────────────────────────────────────────────────────────────────────┘┘ #
function git_api_secret_set {
    local api_secret=${1:-$(</dev/stdin)}
    export __gitlab_api_secret__="${api_secret}"
    # Check if the credential works
    local __gitlab_api_secret_valid__=1
    local gitlab_api_entrypoint="$(
        printf "%s/" \
            "https://$(git_repo_info "host")" \
            "api" \
            "v${git_api_version}" \
            "version"
    )"
    local output="$(
        git_api \
            "${gitlab_api_entrypoint}" |
            jq '.version'
    )"
    if [[ ! "$output" == "null" ]]; then
        local __gitlab_api_secret_valid__=0
    fi
    return ${__gitlab_api_secret_valid__}
}
# ────────────────────────────────── <end> ─────────────────────────────────── #

# ============================ > git_repo_info < ============================= #

# ┌┌────────────────────────────────────────────────────────────────────────┐┐ #
# ││ `git_repo_info`                                                        ││ #
# ││                                                                        ││ #
# ││ Obtain relevant information about the repo this script is called from  ││ #
# ││                                                                        ││ #
# ││ Input:                                                                 ││ #
# ││ $1 : type (string): The type of information to be returned. One of:    ││ #
# ││ host / owner / project / git_url / registry / api                      ││ #
# ││                                                                        ││ #
# ││ Output:                                                                ││ #
# ││ The requested information as string                                    ││ #
# ││                                                                        ││ #
# ││ Usage:                                                                 ││ #
# ││ git_repo_info <type>                                                   ││ #
# ││                                                                        ││ #
# ││ Examples:                                                              ││ #
# ││ git_repo_info "registry"                                               ││ #
# └└────────────────────────────────────────────────────────────────────────┘┘ #
function git_repo_info {
    local type="${1}"
    # Get repo URL, replace the git@ and .git at begin / end,
    # and replace all / or : with ; (to split the string)
    local repo_info=$(
        echo "$(git config --get remote.origin.url)" |
            sed \
                -e 's/\.git$//g' \
                -e 's/^.*@//g' \
                -e 's/[\/:]/;/g'
    )

    # Obtain the git instance, user, and project
    local host=$(echo "${repo_info}" | awk -F\[\;\] '{print $1}')
    local owner=$(echo "${repo_info}" | awk -F\[\;\] '{print $2}')
    local proj=$(echo "${repo_info}" | awk -F\[\;\] '{print $3}')

    shopt -s nocasematch
    # Format output according to requested info
    if [[ ${type} == "host" ]]; then
        # The host / gitlab instance
        echo "${host}"
    elif [[ ${type} == "owner" ]]; then
        # The repo's owner
        echo ${owner}
    elif [[ ${type} == "project" ]]; then
        # The repo's name
        echo ${proj}
    elif [[ ${type} == "git_url" ]]; then
        # The repo's git url
        echo "git@${host}/${owner}/${proj}.git"
    elif [[ ${type} == "registry" ]]; then
        # The repo's registry
        echo "${host}:${git_registry_port}#${owner}/${proj}/"
    elif [[ ${type} == "api" ]]; then
        # The repo's API project endpoint
        echo "https://${host}/api/v${git_api_version}/projects/${owner}%2F${proj}/"
    fi
    shopt -u nocasematch
    exit 0
}

# ────────────────────────────────── <end> ─────────────────────────────────── #

function git_token_id_delete {
    # Delete all tokens with the entered ids
    echo "${1}" | while IFS= read -r token_id; do
        git_token_delete "$token_id"
    done
}

# =========================== > git_token_create < =========================== #
# ┌┌────────────────────────────────────────────────────────────────────────┐┐ #
# ││ `git_token_create`                                                     ││ #
# ││                                                                        ││ #
# ││ Create a new project access token                                      ││ #
# ││                                                                        ││ #
# ││ Output:                                                                ││ #
# ││ null                                                                   ││ #
# ││                                                                        ││ #
# ││ Examples:                                                              ││ #
# ││ git_token_create                                                       ││ #
# └└────────────────────────────────────────────────────────────────────────┘┘ #
function git_token_create {
    local token_infos="$(date '+%Y-%m-%d_%H:%M:%S')"
    local expiry_date=$(date -d "${token_duration}" "+%Y-%m-%d")
    echo "$(
        git_api \
            --request POST \
            --data-urlencode "name=$(git_token_name ${token_infos})" \
            --data-urlencode "scopes[]=read_registry" \
            --data-urlencode "scopes[]=write_registry" \
            --data-urlencode "scopes[]=read_repository" \
            --data-urlencode "scopes[]=write_repository" \
            --data-urlencode "expires_at=${expiry_date}" \
            --data-urlencode "access_level=30" \
            "$(git_repo_info api)access_tokens"
    )"
}
# ────────────────────────────────── <end> ─────────────────────────────────── #

# =========================== > git_token_delete < =========================== #

# ┌┌────────────────────────────────────────────────────────────────────────┐┐ #
# ││ `git_token_delete`                                                     ││ #
# ││                                                                        ││ #
# ││ Delete a gitlab token  based on its id via API                         ││ #
# ││                                                                        ││ #
# ││ Input:                                                                 ││ #
# ││ "$1" : token_id (string): The token id to delete                       ││ #
# ││                                                                        ││ #
# ││ Output:                                                                ││ #
# ││ null                                                                   ││ #
# ││                                                                        ││ #
# ││ Usage:                                                                 ││ #
# ││ git_token_delete <token_id>                                            ││ #
# ││                                                                        ││ #
# ││ Examples:                                                              ││ #
# ││ git_token_delete 1234                                                  ││ #
# └└────────────────────────────────────────────────────────────────────────┘┘ #
function git_token_delete {
    local token_id="${1}"
    echo "$(
        git_api \
            --request DELETE \
            "$(git_repo_info api)access_tokens/${token_id}"
    )"
}
# ────────────────────────────────── <end> ─────────────────────────────────── #

# =========================== > git_token_id_get < =========================== #

# ┌┌────────────────────────────────────────────────────────────────────────┐┐ #
# ││ `git_token_id_get`                                                     ││ #
# ││                                                                        ││ #
# ││ Retrieve latest gitlab token that matches output pattern of            ││ #
# ││ git_token_name                                                         ││ #
# ││                                                                        ││ #
# ││ Output:                                                                ││ #
# ││ token_id                                                               ││ #
# ││                                                                        ││ #
# ││ Examples:                                                              ││ #
# ││ git_token_id_get                                                       ││ #
# └└────────────────────────────────────────────────────────────────────────┘┘ #
function git_token_id_get {
    # Retrieve all tokens
    tokens="$(
        git_api \
            "$(git_repo_info api)access_tokens"
    )"

    # Identify token(s) that match the pattern returned by git_token_name,
    # but are not revoked yet (required to exclude previous versions of a token
    # that has been rotated)
    token_ids=$(
        echo "$tokens" |
            jq --arg pattern "$(git_token_name ".*")" -r "$(
                printf "%s" \
                    '.[]' \
                    '|' \
                    'select(.name | test($pattern))' \
                    '|' \
                    'select(.active)' \
                    '|' \
                    'select(.revoked | not)' \
                    '|' \
                    '.id'
            )"
    )
    # Delete all tokens except the latest one
    if [ "$(echo "$token_ids" | jq -s 'length')" -gt 1 ]; then
        git_token_id_delete "$(echo "$token_ids" | head -n -1)"
    fi
    echo "$(echo "${token_ids}" | tail -n 1)"
}
# ────────────────────────────────── <end> ─────────────────────────────────── #

# ============================ > git_token_name < ============================ #

# ┌┌────────────────────────────────────────────────────────────────────────┐┐ #
# ││ `git_token_name`                                                       ││ #
# ││                                                                        ││ #
# ││ Create standardized git token name                                     ││ #
# ││                                                                        ││ #
# ││ Input:                                                                 ││ #
# ││ $1 : content (string): additional content included in the name         ││ #
# ││                                                                        ││ #
# ││ Output:                                                                ││ #
# ││ output_of_git_token_name                                               ││ #
# ││                                                                        ││ #
# ││ Usage:                                                                 ││ #
# ││ git_token_name <content>                                               ││ #
# ││                                                                        ││ #
# ││ Examples:                                                              ││ #
# ││ git_token_name "2024/02/20 "                                           ││ #
# └└────────────────────────────────────────────────────────────────────────┘┘ #
function git_token_name {
    local content=${1}
    echo "__AUTO_TOKEN_${USER}@${HOST}${HOSTNAME}_${content}__"
}

# ────────────────────────────────── <end> ─────────────────────────────────── #
# ============================ > git_token_read < ============================ #
# ┌┌────────────────────────────────────────────────────────────────────────┐┐ #
# ││ `git_token_read`                                                       ││ #
# ││                                                                        ││ #
# ││ Read a token from a file                                               ││ #
# ││                                                                        ││ #
# ││ Input:                                                                 ││ #
# ││ $1 : file (string): The file path to the token                         ││ #
# ││                                                                        ││ #
# ││ Output:                                                                ││ #
# ││ The token, or "" if the file does not exist                            ││ #
# ││                                                                        ││ #
# ││ Usage:                                                                 ││ #
# ││ git_token_read <file>                                                  ││ #
# ││                                                                        ││ #
# ││ Examples:                                                              ││ #
# ││ git_token_read "/path/to/file"                                         ││ #
# └└────────────────────────────────────────────────────────────────────────┘┘ #
function git_token_read {
    local file=$(eval "echo "${1}"")
    echo "$(cat ${file} 2>"/dev/null" || echo "")"
}
# ────────────────────────────────── <end> ─────────────────────────────────── #
# =========================== > git_token_renew < ============================ #

# ┌┌────────────────────────────────────────────────────────────────────────┐┐ #
# ││ `git_token`                                                            ││ #
# ││                                                                        ││ #
# ││ Create new or rotate existing token                                    ││ #
# ││                                                                        ││ #
# ││ Input:                                                                 ││ #
# ││ $1 : tokenfile (string): Path to a file where the token is stored.     ││ #
# ││ $2 : api_secret (string): Secret (personal token) for gitlab API       ││ #
# ││                                                                        ││ #
# ││ Output:                                                                ││ #
# ││ The token is written to the tokenfile                                  ││ #
# ││                                                                        ││ #
# ││ Usage:                                                                 ││ #
# ││ git_token_renew <tokenfile> <api_secret>                               ││ #
# ││                                                                        ││ #
# ││ Examples:                                                              ││ #
# ││ git_token_renew "path/to/file" "glpat-aG2fJfixfGub6ULt2L5_"            ││ #
# └└────────────────────────────────────────────────────────────────────────┘┘ #
function git_token_renew {
    local tokenfile=$(eval "echo "${1}"")
    { # Get secret as argument
        # or (more secure) from stdin, e.g. piping
        git_api_secret_set "${2:-$(</dev/stdin)}"
    } && {
        # If the secret is valid, we can rotate or create a token
        local token_id=$(git_token_id_get)

        if [ ! -z ${token_id} ]; then
            echo "Rotating token!"
            local new_token="$(git_token_rotate ${token_id})"
            if [[ $new_token =~ "400 Bad request" ]]; then
                local token_id=$(git_token_id_get)
                echo "Rotating token failed! Revoking token and creating new one." >&2
                git_token_delete "${token_id}"
                local new_token=$(git_token_create)
            fi
        else
            echo "Creating token!"
            local new_token=$(git_token_create)
        fi
        token_value=$(
            echo "$new_token" |
                jq -r '.token' |
                tail -n 1
        )
        make_file_path "${tokenfile}"
        # Set file permissions
        chmod u=rw,g=,o= "${tokenfile}"
        # Print token to file
        echo "${token_value}" >"${tokenfile}"
    } || {
        # If the secret is invalid, do nothing
        echo "API secret invalid -- skipping \`git_token_renew\`!" >&2
        return 0
    }
}

# ────────────────────────────────── <end> ─────────────────────────────────── #

# =========================== > git_token_rotate < =========================== #
# ┌┌────────────────────────────────────────────────────────────────────────┐┐ #
# ││ `git_token_rotate`                                                     ││ #
# ││                                                                        ││ #
# ││ Rotate an existing token based on its id via API                       ││ #
# ││                                                                        ││ #
# ││ Input:                                                                 ││ #
# ││ $1 : token_id (string): The token's id                                 ││ #
# ││                                                                        ││ #
# ││ Output:                                                                ││ #
# ││ null                                                                   ││ #
# ││                                                                        ││ #
# ││ Usage:                                                                 ││ #
# ││ git_token_rotate <token_id>                                            ││ #
# ││                                                                        ││ #
# ││ Examples:                                                              ││ #
# ││ git_token_rotate 1234                                                  ││ #
# └└────────────────────────────────────────────────────────────────────────┘┘ #
function git_token_rotate {
    local token_id="${1}"
    local expiry_date=$(date -d "${token_duration}" "+%Y-%m-%d")
    echo "$(
        git_api \
            --request POST \
            --data-urlencode "expires_at=${expiry_date}" \
            "$(git_repo_info api)access_tokens/${token_id}/rotate"
    )"
}
# ────────────────────────────────── <end> ─────────────────────────────────── #

# =========================== > git_token_valid < ============================ #
# ┌┌────────────────────────────────────────────────────────────────────────┐┐ #
# ││ `git_token_valid`                                                      ││ #
# ││                                                                        ││ #
# ││ Check whether a credential grants access                               ││ #
# ││ to the repo's container registry                                       ││ #
# ││                                                                        ││ #
# ││ Input:                                                                 ││ #
# ││ $1 : credential (string): The credential for accessing the registry    ││ #
# ││                                                                        ││ #
# ││ Output:                                                                ││ #
# ││ 0 if login succeeds, else 1                                            ││ #
# ││                                                                        ││ #
# ││ Usage:                                                                 ││ #
# ││ git_token_valid <credential>                                           ││ #
# ││                                                                        ││ #
# ││ Examples:                                                              ││ #
# ││ git_token_valid "glpat-aG2fJfixfGub6ULt2L5_"                           ││ #
# └└────────────────────────────────────────────────────────────────────────┘┘ #
function git_token_valid {
    local credential="${1:-$(</dev/stdin)}"
    {
        check_dependency "docker" >/dev/null 2>&1
    } && {
        # Use docker login to check credential
        echo "${credential}" |
            git_token_valid_docker
        return $?
    } ||
        {
            check_dependency "enroot" >/dev/null 2>&1
        } && {
        # Use enroot import to check credential
        echo "${credential}" |
            git_token_valid_enroot
        return $?
    }

}
# ────────────────────────────────── <end> ─────────────────────────────────── #
# ======================= > git_token_valid_docker < ======================== #
# ┌┌────────────────────────────────────────────────────────────────────────┐┐ #
# ││ `git_token_valid_docker`                                              ││ #
# ││                                                                        ││ #
# ││ Check whether a credential grants access                               ││ #
# ││ to the repo's container registry via `docker login`                    ││ #
# ││                                                                        ││ #
# ││ Input:                                                                 ││ #
# ││ $1 : credential (string): The credential for accessing the registry    ││ #
# ││                                                                        ││ #
# ││ Output:                                                                ││ #
# ││ 0 if login succeeds, else 1                                            ││ #
# ││                                                                        ││ #
# ││ Usage:                                                                 ││ #
# ││ git_token_valid_docker <credential>                                   ││ #
# ││                                                                        ││ #
# ││ Examples:                                                              ││ #
# ││ git_token_valid_docker "glpat-aG2fJfixfGub6ULt2L5_"                   ││ #
# └└────────────────────────────────────────────────────────────────────────┘┘ #
function git_token_valid_docker {
    local credential="${1:-$(</dev/stdin)}"

    if [ ! -z ${credential} ]; then
        echo "${credential}" |
            docker login \
                --username "__docker_token_valid_$(date '+%Y-%m-%d_%H-%M-%S')__" \
                --password-stdin \
                "$(git_repo_info "registry")" \
                > \
                /dev/null 2>&1
        return $?
    else
        return 1
    fi
}
# ────────────────────────────────── <end> ─────────────────────────────────── #

# ======================= > git_token_valid_enroot < ======================== #

# ┌┌────────────────────────────────────────────────────────────────────────┐┐ #
# ││ `git_token_valid_enroot`                                              ││ #
# ││                                                                        ││ #
# ││ Check whether a credential grants access                               ││ #
# ││ to the repo's container registry via `enroot import`                   ││ #
# ││                                                                        ││ #
# ││ Input:                                                                 ││ #
# ││ $1 : credential (string): The credential for accessing the registry    ││ #
# ││                                                                        ││ #
# ││ Output:                                                                ││ #
# ││ 0 if login succeeds, else 1                                            ││ #
# ││                                                                        ││ #
# ││ Usage:                                                                 ││ #
# ││ git_token_valid_enroot <credential>                                   ││ #
# ││                                                                        ││ #
# ││ Examples:                                                              ││ #
# ││ git_token_valid_enroot "glpat-aG2fJfixfGub6ULt2L5_"                   ││ #
# └└────────────────────────────────────────────────────────────────────────┘┘ #
function git_token_valid_enroot {
    local credential="${1:-$(</dev/stdin)}"

    if [ ! -z ${credential} ]; then
        result="$(
            export CISPA_GITLAB_TOKEN="$credential"
            enroot import docker://projects.cispa.saarland:5005#c01sile/containr_test \
                2>&1 >/dev/null
        )"
        if [[ $result =~ "Authentication succeeded" ]]; then
            return 0
        else
            return 1
        fi
    else
        return 1
    fi
}
# ────────────────────────────────── <end> ─────────────────────────────────── #

# ============================ > make_file_path < ============================ #
# ┌┌────────────────────────────────────────────────────────────────────────┐┐ #
# ││ `make_file_path`                                                       ││ #
# ││                                                                        ││ #
# ││ Create path a file, including parent directories                       ││ #
# ││                                                                        ││ #
# ││ Input:                                                                 ││ #
# ││ $1 : file (string): The file's path                                    ││ #
# ││                                                                        ││ #
# ││ Output:                                                                ││ #
# ││ null                                                                   ││ #
# ││                                                                        ││ #
# ││ Usage:                                                                 ││ #
# ││ make_file_path <file>                                                  ││ #
# ││                                                                        ││ #
# ││ Examples:                                                              ││ #
# ││ make_file_path "/path/to/file"                                         ││ #
# └└────────────────────────────────────────────────────────────────────────┘┘ #
function make_file_path {
    # Make sure path is fully expanded, as mkdir and > do not expand ~
    local file=$(eval "echo "${1}"")
    # Create path
    mkdir -p "$(dirname "${file}")"
    # Create file
    touch "${file}"
        # Set file permissions
    chmod u=rw,g=,o= "${file}"
}
# ────────────────────────────────── <end> ─────────────────────────────────── #
