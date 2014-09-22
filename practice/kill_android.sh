#!/bin/sh

processes = `ps aux | grep $1`

for process in $processes
do
	kill $process
done