#!/usr/bin/env bash

# This option will make the script exit when there is an error
set -o errexit
# This option will make the script exit when it tries to use an unset variable
set -o nounset

main() {
  # A string variable containing only the FIRST argument passed to the script,
  # you can use input=$@ to get a string with ALL arguments
  local +r SquareNum=$1
  local +r re='^[0-9]+$'
  if [[ $SquareNum =~ $re ]] || $(( $SquareNum < 1 || $SquareNum > 64 ))
  then
    echo "Error: invalid input"
    exit 1
  fi

  # Add your code here
  local +r NumGrains=1
  local index=0
  while (( index < (SquareNum - 1) ))
  do
    NumGrains=$(bc <<< "$NumGrains * 2" )
    index=$(( index + 1 ))
  done

  echo $NumGrains
}

# Calls the main function passing all the arguments to it via '$@'
# The argument is in quotes to prevent whitespace issues
main "$@"