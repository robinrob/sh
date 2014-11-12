#!/usr/bin/env sh

source $SHLOG_PATH


gfind . -regextype posix-egrep -regex '.*/2014_(09|10)_[0-9]{2}_[0-9]{2}_[0-9]{2}_[0-9]{2}\.txt'
