#!/usr/bin/env sh

echo "Robin Smith" | tr -d ' '

echo "Robin Smith" | tr -d " "

EMPTY_STRING=`echo "   "`
echo "Pre-trimmed string: <$EMPTY_STRING>"

EMPTY_STRING=`echo $EMPTY_STRING | tr -d ' '`
echo "Trimmed string: <$EMPTY_STRING>"

if [ -n "$EMPTY_STRING" ]
then
	echo "Trimmed string is NOT null!"
else
	echo "Trimmed string is NULL!"
fi

FULL_STRING="Robin Smith"
if [ -n "$FULL_STRING" ]
then
	echo "$FULL_STRING is NOT null!"
else
	echo "$FULL_STRING is NULL!"
fi