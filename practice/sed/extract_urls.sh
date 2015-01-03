#!/usr/bin/env sh

# Used for converting my old system of bookmark aliases into new system using
# text-file as seed for aliases

gsed "s/\(alias \)\([a-z]\+\)\(.\+\)\(http[^\ '\"]\+\)\(.\)\+/\2::safari::\4/g"
