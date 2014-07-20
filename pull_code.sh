#!/bin/bash

source ~/.zshrc
source colors

blue "REPOS: $REPOS
"

rake save

function rake() {
	for repo in $REPOS
	do
		green "Saving repo: $repo"
		cd $repo
		rake $1
	done	
}