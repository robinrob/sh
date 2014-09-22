#!/bin/bash

date_stamp=`date +"%y-%m-%d-%H-%M-%S"`
sudo mtr --report --report-cycles=300 54.77.27.21 > 'kempinski_results_'$date_stamp'.txt'
