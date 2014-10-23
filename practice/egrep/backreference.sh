#!/usr/bin/env sh

# Use a back reference to match doubled words:
echo robin robin robin | egrep '([a-zA-Z]+) \1'
