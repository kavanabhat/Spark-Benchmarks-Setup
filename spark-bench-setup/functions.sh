#!/bin/bash

#Method to check if a package is installed or not.
#first param is package name, second is the log file

function check_package(){
    #apt get is idempotent
    #so no need of if condition
    log=$2
    echo "sudo apt install $1" |tee -a $log
    sudo apt install $1 |tee -a $log
}
