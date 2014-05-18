#!/bin/sh

RAKEFILE_REPO=robins-rakefile

git submodule init
git submodule add git@bitbucket.org:robinrob/rakefile.git $RAKEFILE_REPO
ln -s $RAKEFILE_REPO/Rakefile ./
rake save