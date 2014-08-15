#!/bin/bash

BOOL=0

echo "OPTIND starts at $OPTIND"
while getopts ":pqt" optname
  do
    case "$optname" in
      "p")
        echo "Option $optname is specified"
        ;;
      "q")
        echo "Option $optname has value $OPTARG"
        ;;
      "t")
		BOOL=1
        ;;	
      "?")
        echo "Unknown option $OPTARG"
        ;;
      ":")
        echo "No argument value for option $OPTARG"
        ;;
      *)
      # Should not occur
        echo "Unknown error while processing options"
        ;;
	esac
		echo "OPTIND is now $OPTIND"
done

echo "Bool: "$BOOL

if [ $BOOL -eq 1 ]
	then
	echo "YES!"
else
	echo "NO"
fi
