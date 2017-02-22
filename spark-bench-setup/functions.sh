#!/bin/bash

#Method to check if a package is installed or not.
#first param is package name, second is the log file

function check_package(){

    echo "Checking if $1 is installed" | tee -a $log
    log=$2

    dpkg -s $1 > /dev/null
    if [ $? -eq 0 ]; then
		echo "$1 already installed" |tee -a $log
	else
		echo "Installing $1" | tee -a $log
		echo "sudo apt install $1" |tee -a $log
		sudo apt install $1
	fi
}
