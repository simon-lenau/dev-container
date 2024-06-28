#!/bin/sh
export install_dependencies="ubuntu R"

if .gitlab-ci/needs_dependencies "R"; then
    echo "R: yes"
fi

if .gitlab-ci/needs_dependencies "python"; then
    echo "python: yes"
fi

if .gitlab-ci/needs_dependencies "ubuntu"; then
    echo "ubuntu: yes"
fi
