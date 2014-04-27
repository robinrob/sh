#!/bin/bash

source ~/.zshrc
source colors

blue "REPOS: $REPOS
"

for repo in $REPOS
do
	green "Saving repo: $repo"
	cd $repo
	rake save
done