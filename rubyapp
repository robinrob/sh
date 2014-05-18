#!/bin/sh

DESTINATION=$1

echo "Cloning ruby-app repo"
git clone -b master git@bitbucket.org:robinrob/ruby-app.git $DESTINATION

cd $DESTINATION

echo "Re-initialising git"
git remote rm origin
rm -rf .git
git init

echo "Initialising submodules"
git submodule add --force git@bitbucket.org:robinrob/rakefile.git robins-rakefile
git submodule init
git submodule update

echo "Sym-linking Rakefile"
rm Rakefile
ln -s robins-rakefile/Rakefile ./