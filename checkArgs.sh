#!/bin/bash -eux

# Check that argument 1 is not null without causing an error
if [[ -n "$1" ]]
then
	echo "Yeah mate"
else
	echo "No mate"
fi
