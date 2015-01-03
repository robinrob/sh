#!/usr/bin/env sh

/usr/local/bin/gls -ltr --color=none . | awk '{print $(NF-1),"\t",$NF}' | tail +2
