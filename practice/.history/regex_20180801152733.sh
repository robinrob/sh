#!/usr/bin/env sh

local +r Num=$1

re='^[0-9]+$'
if ! [[ $Num =~ $re ]] ; then
   echo "error: Not a number" >&2; exit 1
fi
