#!/usr/bin/env sh

source $SH_HOME/colors.sh

green "method 1"
find . \( ! -regex '.*/\..*' \) -type f -depth 1

green "method 2"
find . \( ! -name '.*'  \) -type f -depth 1