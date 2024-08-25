#!/usr/bin/env bash

get_latest_release() {
    platform=${1}
    arch=${2}
    bin_type="${3}"

    # Grab the first commit SHA since as this script assumes it will be the
    # latest.
    commit_id=$(curl "https://update.code.visualstudio.com/api/commits/${bin_type}/${platform}-${arch}" | sed s'/^\["\([^"]*\).*$/\1/')

    # These work:
    # https://update.code.visualstudio.com/api/commits/stable/win32-x64
    # https://update.code.visualstudio.com/api/commits/stable/linux-x64
    # https://update.code.visualstudio.com/api/commits/insider/linux-x64

    # these do not work:
    # https://update.code.visualstudio.com/api/commits/stable/darwin-x64
    # https://update.code.visualstudio.com/api/commits/stable/linux-alpine
    printf "%s" "${commit_id}"
}

get_latest_release "win32" "x64" "stable"