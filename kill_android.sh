#!/bin/sh

processes = `ps aux | grep android`

for process in processes
do
	