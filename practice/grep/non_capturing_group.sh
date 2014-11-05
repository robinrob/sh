#!/usr/bin/env sh

echo "name: robin andrew smith" | ggrep -Po '(?<=name: ).+'
