#!/usr/bin/env zsh

source $ZSHCOLORS_PATH

./create_files_with_spaces.sh

gfind files_with_spaces -name 'test*' -type f
