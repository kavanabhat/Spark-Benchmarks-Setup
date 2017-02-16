#!/bin/bash -l
echo -e
if [ -z ${WORKDIR} ]; then
   echo "Please set your work directory environment variable - "WORKDIR"."
   exit 1
fi

HIBENCH_UTILS_DIR=$WORKDIR/Spark-Benchmarks-Setup/hibench-setup  
current_time=$(date +"%Y.%m.%d.%S")

if [ ! -d ${HIBENCH_UTILS_DIR}/wdir ];
then
    mkdir ${HIBENCH_UTILS_DIR}/wdir
fi

HIBENCH_WORK_DIR=$WORKDIR/Spark-Benchmarks-Setup/hibench-setup/wdir

if [ ! -d ${HIBENCH_WORK_DIR}/hibench_logs ];
then
    mkdir ${HIBENCH_WORK_DIR}/hibench_logs
fi

log=${HIBENCH_WORK_DIR}/hibench_logs/hibench_install_$current_time.log

echo -e 'Node server details for existing hadoop and spark setup' 
MASTER=`hostname`
echo -e 'MASTER='$MASTER'' | tee -a $log

SLAVES=`cat ${HADOOP_CONF_DIR}/slaves | tr '\n' ','| sed 's/\,$//'`
echo -e 'SLAVES='$SLAVES'' | tee -a $log
echo "---------------------------------------------" | tee -a $log


#Hibench git repository url
HIBENCH_GIT_URL='https://github.com/intel-hadoop/HiBench.git'
echo -e 'HIBENCH GIT_URL='$HIBENCH_GIT_URL'' | tee -a $log

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

if [ ! -x /usr/bin/python ] 
then
   echo "Python is not installed on Master, so installing Python" | tee -a $log
   sudo apt-get install python >> $log  
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


cd ${HIBENCH_WORK_DIR}
	
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

	
##HiBench setup steps

if [ -d ${HIBENCH_WORK_DIR}/HiBench ];
then
    echo -e 'Removing existing HiBench folder - '${HIBENCH_WORK_DIR}'/HiBench \n' | tee -a $log
	rm -rf ${HIBENCH_WORK_DIR}/HiBench &>/dev/null
fi
	
if curl --output /dev/null --silent --head --fail ${HIBENCH_GIT_URL}
then
    git clone --recursive ${HIBENCH_GIT_URL} | tee -a $log
	echo -e 
	echo -e 'HiBench cloning done at - '${HIBENCH_WORK_DIR}'/HiBench' | tee -a $log
				 
else
    echo -e
    echo 'This URL - '${HIBENCH_GIT_URL}' does not exist. Please check url for HiBench git repository.' | tee -a $log
	exit 1
fi 
	
echo "---------------------------------------------" | tee -a $log
	
cp ${HIBENCH_WORK_DIR}/HiBench/conf/hadoop.conf.template ${HIBENCH_WORK_DIR}/HiBench/conf/hadoop.conf

sed -i 's|^hibench.hadoop.home.*|hibench.hadoop.home    '${HADOOP_HOME}'|g' ${HIBENCH_WORK_DIR}/HiBench/conf/hadoop.conf
sed -i 's|^hibench.hdfs.master.*|hibench.hdfs.master       hdfs://'${MASTER}':9000 |g' ${HIBENCH_WORK_DIR}/HiBench/conf/hadoop.conf


cp ${HIBENCH_WORK_DIR}/HiBench/conf/spark.conf.template ${HIBENCH_WORK_DIR}/HiBench/conf/spark.conf

sed -i 's|^hibench.spark.home.*|hibench.spark.home    '${SPARK_HOME}'|g' ${HIBENCH_WORK_DIR}/HiBench/conf/spark.conf
	
cd ${HIBENCH_WORK_DIR}/HiBench

echo -e "Building Hibench"

${HIBENCH_WORK_DIR}/HiBench/bin/build-all.sh | tee -a $log
echo -e
echo -e 'Please edit memory and executor related parameter as per your requirement in '{HIBENCH_WORK_DIR}'/HiBench/conf/spark.conf file'