#!/bin/bash

#Method to install maven on redhat
#maven is not available as a package so 
#need to extract and install
function install_mvn_redhat (){
	mvn -version >> /dev/null
        export log=$1 
	if [ $? = 0 ]
	then
		echo "Maven already installed" | tee -a $log
		return
	fi
	java -version >> /dev/null
	if [ $? -ne 0 ]
	then
		echo "JAVA not installed or JAVA_HOME is not set..aborting! Please check  java is available on the path" | tee -a $log
		exit 1
	fi

	cd ~
	if [ ! -f apache-maven-3.3.9-bin.tar.gz ]
	then
		wget http://www-eu.apache.org/dist/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz
	fi

	if [ ! -d apache-maven-3.3.9 ]
	then
		rm -rf apache-maven-3.3.9
		tar xzf apache-maven-3.3.9-bin.tar.gz
	fi

	echo "#StartMAVEN variables" >> tmp_source
	echo "export M2_HOME=~/apache-maven-3.3.9" >> tmp_source
	echo 'export PATH=${M2_HOME}/bin:${PATH}' >> tmp_source
	echo "#EndMAVEN variables" >> tmp_source
	sed -i '/#StartMAVEN/,/#EndMAVEN/d' $HOME/.bashrc
	cat tmp_source >> ~/.bashrc
	rm tmp_source
	source ~/.bashrc
	mvn -version
	if [ $? != 0 ]
	then
		echo "Some error occured, maven installation failed"
		exit 1
	else
		echo "Maven installation verified!"
	fi

}
#Method to check if a package is installed or not.
#first param is package name, second is the log file

function check_package(){
   log=$2
   package=$1
   #apt get is idempotent
   #so no need of if condition
    if [ -f /usr/bin/apt-get ]; then
	sudo apt-get -y install $1 | tee -a $log
    else
        if [ "$package" = "maven" ]
        then
            install_mvn_redhat $log
        else 
            sudo yum -y install $1 | tee -a $log
        fi
    fi
}
