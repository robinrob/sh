#!/usr/bin/env sh

source $COLORS_PATH

text="robin\nandrew\nsmith\nis\nawesome!"
green $text

echo

echo $text | sed '/^andrew$/d'
