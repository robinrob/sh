#!/usr/bin/env sh

source $SH_HOME/colors.sh

green "method 1"
find . -regex '.*/[a-zA-Z0-9_-]*' -depth 1 -type f

green "method 2"
find . \( ! -regex '.*/.*[.].*' \) -type f -depth 1