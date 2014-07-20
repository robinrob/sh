DESTINATION=$1

git clone -b master git@bitbucket.org:robinrob/py-app.git $DESTINATION
cd $DESTINATION
fab install -f $PYAPP_HOME/fabfile.py
