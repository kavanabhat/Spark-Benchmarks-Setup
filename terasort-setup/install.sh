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
#check for zip installed or not
if [ ! -x /usr/bin/zip ] 
then
   echo "zip is not installed on Master, so getting installed" | tee -a $log
   sudo apt-get install zip | tee -a $log
fi

#check for maven installed or not

if [ ! -x /usr/bin/mvn ] 
then
   echo "maven is not installed on Master, so getting installed" | tee -a $log
   sudo apt-get install maven | tee -a $log
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
    echo -e 'Removing existing HiBench folder - '${TERASORT_WORK_DIR}'/spark-terasort \n' | tee -a $log
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

##Hadoop config updates
	
	
cd ${TERASORT_WORK_DIR}/spark-terasort

echo -e "Building terasort"

mvn install  | tee -a $log
echo -e
echo -e
