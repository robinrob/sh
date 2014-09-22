#!/bin/sh
for repo in `cat repos.txt`;
do
  git clone -b master git@bitbucket.org:robinrob/$repo
done
