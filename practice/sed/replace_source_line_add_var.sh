#!/usr/bin/env sh

source $SHLOG_PATH


log "gsed -i 's/\ \([a-z]\+\)\.zsh/\ $\ZDOT_HOME\/\1\.zsh/g' *.zsh"
