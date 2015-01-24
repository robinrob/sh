#!/usr/bin/env zsh

source $ZSHCOLORS_PATH

./create_files_with_spaces.sh

green "Before:"
ls files_with_spaces

gfind files_with_spaces -name 'test*' -type f -print0 | gxargs -0 rm

yellow "After:"
ls files_with_spaces
