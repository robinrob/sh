#!/usr/bin/env sh

source $SHLOG_PATH


text="hello\nrobin"

cyan "Multiline grep. -N is required which specifies what type of newline to
look for"

log "echo \$text | pcregrep -M -N CR 'hello.*robin'"
