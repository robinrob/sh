#!/usr/bin/env zsh

# This option will make the script exit when there is an error
set -o errexit
# This option will make the script exit when it tries to use an unset variable
set -o nounset

main() {
  # A string variable containing only the FIRST argument passed to the script,
  # you can use input=$@ to get a string with ALL arguments

  # Add your code here
  local NumGrains=1

  local +r index=0
  while (( index < 64 ))
  do
    NumGrains=$(( NumGrains * 2 ))
    index=$(( index + 1 ))
  done

  echo $NumGrains
}

# Calls the main function passing all the arguments to it via '$@'
# The argument is in quotes to prevent whitespace issues
main

