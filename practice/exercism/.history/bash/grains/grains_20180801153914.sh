#!/usr/bin/env bash

# This option will make the script exit when there is an error
set -o errexit
# This option will make the script exit when it tries to use an unset variable
set -o nounset

main() {
  # A string variable containing only the FIRST argument passed to the script,
  # you can use input=$@ to get a string with ALL arguments
  local +r input=$1

  local +r IntRegex='^[0-9]+$'
  
  if [[ input == "total" ]]
  then
    echo "18446744073709551615"
    return 0
  fi

  if ! [[ $input =~ $IntRegex ]] || (( $input < 1 || $input > 64 ))
  then
    echo "Error: invalid input"
    return 1
  fi

  # Add your code here
  local +r NumGrains=1
  local index=0
  while (( index < (input - 1) ))
  do
    NumGrains=$(bc <<< "$NumGrains * 2" )
    index=$(( index + 1 ))
  done

  echo $NumGrains
  return 0
}

# Calls the main function passing all the arguments to it via '$@'
# The argument is in quotes to prevent whitespace issues
main "$@"