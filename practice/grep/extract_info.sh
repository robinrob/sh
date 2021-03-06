#!/bin/bash

grep -o '<h5>[a-zA-Z, ]*</h5>' photos-animals.html | grep -o '[!<]'

grep -o '<h5>[a-zA-Z, ]*</h5>' photos-animals.html | grep -x -o '<h5>' > locations.txt

grep -o '<h5>[0-9/]*</h5>' photos-animals.html > dates.txt

grep -o '[a-z0-9_]*.JPG' photos-animals.html > names.txt

grep -o '.*.JPG' photos-animals.html > names.txt

