#!/bin/bash

COMMAND_STRING_1="xml sel -t -m "/testsuites/testsuite" -v "@tests" -n $device_folder/*.xml"
COMMAND_STRING_2="xml sel -t -v "count\(/testsuites/testsuite/testcase/failure\)" $device_folder/*.xml"

echo "Command string 1: "$COMMAND_STRING_1

echo "Command string 2: "$COMMAND_STRING_2