#!/bin/bash

#Method to check if a package is installed or not.
#first param is package name, second is the log file

function check_package(){
    #apt get is idempotent
   log=$2
   #so no need of if condition
    if [ -f /usr/bin/apt-get ]; then
	sudo apt-get -y install $1 | tee -a $log
    else
	sudo yum -y install $1 | tee -a $log
    fi
}
