#!/bin/bash -eu
##########################################################################################
# RETRIEVE AND DELETE SALESFORCE RESOURCES
##########################################################################################
# This script will download all resources listed in the package.xml file from the
# Salesforce org defined in your build.properties file, generate a destructiveChanges.xml
# file containing all of the resources downloaded, and then delete all of those
# resources from Salesforce.
##########################################################################################
DETAILS="$1"

source colors.sh

print_details()
{
	IFS="
	"
	for detail in $1
	do
		format_line $detail
	done
}

format_line()
{
	IFS="
	"
	key=`echo "$1" | awk -F::'{printf "%-30s", $1}'`
	value=`echo "$1" | awk -F::'{printf "%-30s", $2}'`
	green $key && default ": " && red $value"\n"
}

###################################################
# Script variables
###################################################
MSG_BORDER="#####################################################################"
CHECK_DETAILS_MSG="IMPORTANT: Deployment details - check before continuing!!!"
CONFIRMATION_MSG="Are these details correct? [Y/n]: "
echo -e "\n"${MSG_BORDER}"\n"${CHECK_DETAILS_MSG}"\n"${MSG_BORDER}"\n"

print_details "$DETAILS"

echo -e "\n"

echo -e ${MSG_BORDER}
read -p "$CONFIRMATION_MSG" CONFIRMATION
echo -e ${MSG_BORDER}
if [[ $CONFIRMATION != "Y" ]]
	then
	echo "Aborted."
	exit 1
fi
