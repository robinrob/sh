#!/usr/bin/env sh

source $SHLOG_PATH

str="robin buko123 smith"


log "echo $str | gsed 's/\([a-z]\+\)[0-9]\+/123\1456/g'"
