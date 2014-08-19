#!/usr/bin/env sh

# Example: ./exec_args.sh "git status"

function doit {
	cmd=$@
	$cmd
}

doit $@
