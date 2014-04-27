#!/bin/sh

for repo in repos;
do
	cd $repo
	rake save
done