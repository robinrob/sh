#!/usr/bin/env zsh

source $ZSHCOLORS_PATH

./create_files_with_spaces.sh

IFS="
"
for file in $(gfind files_with_spaces -name 'test*' -type f | gxargs -0); do; print -r $file; done
