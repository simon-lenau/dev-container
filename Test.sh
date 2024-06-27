#!/usr/bin/env bash

printf ">%b<\n" \
    "$(
        (
            echo A
            echo B
            echo C
        ) |
            paste -sd';' - | sed 's/;/\\\n/g'
    )"
