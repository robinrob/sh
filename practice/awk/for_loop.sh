#!/usr/bin/env sh

source $SHLOG_PATH

ls -ltr | gawk '{for(i=4;i<NF;i++) printf "%s",$i OFS;if(NF)printf "%s",$NF;printf ORS}'
