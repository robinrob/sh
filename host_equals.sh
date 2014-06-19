#!/bin/bash

if [ `hostname` == "mercury.local" ]; then
	export DOCUMENTS_HOME="$HOME/Google Drive"
elif [ `hostname` == "venus.local" ]; then
	export DOCUMENTS_HOME="$HOME/Documents"
fi