#!/usr/bin/env sh

source $SHLOG_PATH

echo "client-bellvillerodair, bv-eu-aws-sql01, SQLSERVERAGENT, *, *Azyra*, *, Clauss has asked us to filter, 0" | awk -F'|' 'BEGIN{print "count", "lineNum"}{print gsub(/,/,"") "\t" NR}'
