#!/bin/bash
MSG="Are these details correct? [Y/n] "

echo -e "\n"
read -p "$MSG" CONFIRMATION

echo "Confirmation: ${CONFIRMATION}"

if [[ $CONFIRMATION == "Y" ]]
	then
	echo "Confirmed!"
else
	echo "Aborted"
fi
