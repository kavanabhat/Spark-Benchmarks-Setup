#!/bin/bash -l

if [ -z ${WORKDIR} ]; then
   echo "Please set your work directory environment variable - "WORKDIR"."
   exit 1
fi

TERASORT_UTILS_DIR=$WORKDIR/Spark-Benchmarks-Setup/terasort-setup  
current_time=$(date +"%Y.%m.%d.%S")

if [ ! -d ${TERASORT_UTILS_DIR}/wdir ];
then
    mkdir ${TERASORT_UTILS_DIR}/wdir
fi

TERASORT_WORK_DIR=$WORKDIR/Spark-Benchmarks-Setup/terasort-setup/wdir

if [ ! -d ${TERASORT_WORK_DIR}/terasort_logs ];
then
    mkdir ${TERASORT_WORK_DIR}/terasort_logs
fi

log=${TERASORT_WORK_DIR}/terasort_logs/terasort_install_$current_time.log

echo -e 'Node server details for existing hadoop and spark setup' | tee -a $log
MASTER=`hostname`
echo -e 'MASTER='$MASTER'' | tee -a $log

SLAVES=`cat ${HADOOP_CONF_DIR}/slaves | tr '\n' ','| sed 's/\,$//'`
echo -e 'SLAVES='$SLAVES'' | tee -a $log
echo "---------------------------------------------" | tee -a $log


#Hibench git repository url
TERASORT_GIT_URL='https://github.com/ehiggs/spark-terasort.git'
echo -e 'TERASORT_GIT_URL='$TERASORT_GIT_URL'' | tee -a $log

echo "---------------------------------------------" | tee -a $log
# Ubuntu
if [ $? -ne 0 ]
then
	#check for zip installed or not
	if [ ! -x /usr/bin/zip ] 
	then
	   echo "zip is not installed on Master, so getting installed" | tee -a $log
	   sudo apt-get install -y zip >> $log
	fi

	#check for maven installed or not
	mvn -version &>> /dev/null
	if [ $? -ne 0 ]
	then
	   echo "maven is not installed on Master, so getting installed" | tee -a $log
	   sudo apt-get install -y maven &>> $log
	fi

	if [ ! -x /usr/bin/python ] 
	then
	   echo "Python is not installed on Master, so installing Python" | tee -a $log
	   sudo apt-get install -y python &>> $log  
	fi
else
	#check for zip installed or not
	if [ ! -x /usr/bin/zip ] 
	then
	   echo "zip is not installed on Master, so getting installed" | tee -a $log
	   sudo yum -y install zip &>> $log
	fi

	#check for maven installed or not
    
	mvn -version &>> /dev/null
	if [ $? -ne 0 ]
	then
	    echo "maven is not installed on Master, so getting installed" | tee -a $log
		cd ${HOME}
		if [ ! -f apache-maven-3.3.9-bin.tar.gz ]
		then
			wget http://www-eu.apache.org/dist/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz
		fi

		if [ ! -d apache-maven-3.3.9 ]
		then
			rm -rf apache-maven-3.3.9 &>> $log
			tar xzf apache-maven-3.3.9-bin.tar.gz &>> $log
		fi

		echo "#StartMAVEN variables" >> tmp_b
		echo "export M2_HOME=~/apache-maven-3.3.9" >> tmp_b
		echo 'export PATH=${M2_HOME}/bin:${PATH}' >> tmp_b
		echo "#EndMAVEN variables" >> tmp_b
		sed -i '/#StartMAVEN/,/#EndMAVEN/d' $HOME/.bashrc
		cat tmp_b >> ~/.bashrc
		rm tmp_b
		source ~/.bashrc
		mvn -version &>>/dev/null
		if [ $? != 0 ]
		then
			echo "Maven installation is failed" | tee -a $log
			exit 1
		fi
	fi
	
	if [ ! -x /usr/bin/python ] 
	then
	   echo "Python is not installed on Master, so installing Python" | tee -a $log
	   sudo yum -y install python &>> $log  
	fi
fi



#Logic to create server list 
echo  $SLAVES | grep -v "^#" | tr "," "\n" | grep "$MASTER" &>>/dev/null
if [ $? -eq 0 ]
then
	#if master is also used as data machine 
    SERVERS=$SLAVES
else
    SERVERS=`echo ''$MASTER','$SLAVES''`
fi


cd ${TERASORT_WORK_DIR}
	
##hadoop check
for i in `echo $SERVERS |cut -d "=" -f2 | tr "," "\n" | cut -d "," -f1`
do
	HADOOP=$(ssh $i "grep '^export HADOOP_HOME' $HOME/.bashrc | cut -f2 -d "="") 2>/dev/null
	if [[ $? -eq 0 ]]
	then
		echo -e 'HADOOP setup found on '$i' at '$HADOOP'' | tee -a $log
	else
		echo -e 'HADOOP setup not found on '$i', Please complete hadoop setup using hadoop-cluster-utils.' | tee -a $log
		exit 1 
	fi
done
echo "---------------------------------------------" | tee -a $log
	
##Spark check
for i in `echo $SERVERS |cut -d "=" -f2 | tr "," "\n" | cut -d "," -f1`
do
	ssh $i "grep '^export SPARK_HOME' $HOME/.bashrc | cut -f2 -d "="" &>/dev/null
	if [[ $? -eq 0 ]]
	then
		SPARK=$(ssh $i "grep '^export SPARK_HOME' $HOME/.bashrc | cut -f2 -d "="") 2>/dev/null
		echo -e 'SPARK setup found on '$i' at '$SPARK'' | tee -a $log
	else
		echo -e 'SPARK setup not found on '$i', Please complete spark setup using hadoop-cluster-utils.' | tee -a $log
		exit 1 
	fi
done
	
echo "---------------------------------------------" | tee -a $log

	
##Terasort setup steps

if [ -d ${TERASORT_WORK_DIR}/spark-terasort ];
then
    echo -e 'Removing existing Terasort folder - '${TERASORT_WORK_DIR}'/spark-terasort \n' | tee -a $log
	rm -rf ${TERASORT_WORK_DIR}/spark-terasort &>/dev/null
fi
	
if curl --output /dev/null --silent --head --fail ${TERASORT_GIT_URL}
then
    git clone ${TERASORT_GIT_URL} | tee -a $log
	echo -e 
	echo -e 'Terasort cloning done at - '${TERASORT_WORK_DIR}'/spark-terasort' | tee -a $log
				 
else
    echo -e
    echo 'This URL - '${TERASORT_GIT_URL}' does not exist. Please check url for Terasort git repository.' | tee -a $log
	exit 1
fi 
	
echo "---------------------------------------------" | tee -a $log


cd ${TERASORT_WORK_DIR}/spark-terasort

echo -e "Building terasort, redirecting maven output to $log"

mvn install  >>  $log
if [ $? != 0 ]
then
    echo "Build failed check logs at $log"
    exit 1
fi

echo "Build and installation log at $log"
echo -e
echo -e
