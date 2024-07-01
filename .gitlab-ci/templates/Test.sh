#!/bin/bash
export TO_IMAGE="ABC\\\${SOMEVAR}DEF"
export SOMEVAR=TEST
eval "echo $(echo "$(echo "${TO_IMAGE}" | sed 's|\\\$|\$|g')")"