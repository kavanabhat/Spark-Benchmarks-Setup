#!/bin/bash -l
   
if [ -z ${WORKDIR} ]; then
   echo "Please set your work directory environment variable - "WORKDIR"."
   exit 1
fi

PERFUTILS_DIR=$WORKDIR/Spark-Benchmarks-Setup/spark-perf-setup  
current_time=$(date +"%Y.%m.%d.%S")

if [ ! -d ${PERFUTILS_DIR}/wdir ];
then
    mkdir ${PERFUTILS_DIR}/wdir
fi

PERFWORK_DIR=$WORKDIR/Spark-Benchmarks-Setup/spark-perf-setup/wdir

if [ ! -d ${PERFWORK_DIR}/spark_perf_logs ];
then
    mkdir ${PERFWORK_DIR}/spark_perf_logs
fi

log=${PERFWORK_DIR}/spark_perf_logs/spark_perf_install_$current_time.log

echo -e | tee -a $log

#check for zip installed or not
if [ ! -x /usr/bin/zip ] ; then
   echo "zip is not installed on Master, so getting installed" | tee -a $log
   sudo apt-get install zip >> $log
fi

if [ ! -x /usr/bin/python ] 
then
   echo "Python is not installed on Master, so installing Python" | tee -a $log
   sudo apt-get install python >> $log  
fi


echo -e 'Node server details for existing hadoop and spark setup' 
MASTER=`hostname`
echo -e 'MASTER='$MASTER'' | tee -a $log

SLAVES=`cat ${HADOOP_CONF_DIR}/slaves | tr '\n' ','| sed 's/\,$//'`

echo -e 'SLAVES='$SLAVES'\n' | tee -a $log

sparkversion=`echo $SPARK_HOME | cut -f2 -d "=" | cut -f4 -d "/" | cut -f2 -d "-"` 2>/dev/null

if [ ${sparkversion:0:1} == 2 ]
then
	SPARK_PERF_GIT_URL="https://github.com/a-roberts/spark-perf"
    echo -e 'SPARK_PERF_GIT_URL='$SPARK_PERF_GIT_URL'\n ' | tee -a $log
else
    
	SPARK_PERF_GIT_URL="https://github.com/databricks/spark-perf.git"
    echo -e 'SPARK_PERF_GIT_URL='$SPARK_PERF_GIT_URL'\n '  | tee -a $log
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
	
##SPARK perf setup steps

if [ -d ${PERFWORK_DIR}/spark-perf ];
then
    echo -e 'Removing existing spark-perf folder - '${PERFWORK_DIR}'/spark-perf \n' | tee -a $log
	rm -rf ${PERFWORK_DIR}/spark-perf &>/dev/null
fi

cd ${PERFWORK_DIR}
	
if curl --output /dev/null --silent --head --fail ${SPARK_PERF_GIT_URL}
then
	 git clone ${SPARK_PERF_GIT_URL} | tee -a $log
	 echo -e 
	 echo -e 'spark-perf cloning done at - '${PERFWORK_DIR}'/spark-perf' | tee -a $log
else
     echo -e
	 echo 'This URL - '${SPARK_PERF_GIT_URL}' does not exist. Please check url for Spark perf git repository.' | tee -a $log
	 exit 1
fi 
	
echo "---------------------------------------------" | tee -a $log
	

##Config.py changes 

echo "Configuring changes in config.py file" | tee -a $log
cp ${PERFWORK_DIR}/spark-perf/config/config.py.template ${PERFWORK_DIR}/spark-perf/config/config.py 

##Set hadoop related variables
sed -i 's|^DEFAULT_HOME.*|DEFAULT_HOME="'${SPARK_HOME}'"|g' ${PERFWORK_DIR}/spark-perf/config/config.py 
sed -i 's|^HDFS_URL.*|HDFS_URL = "hdfs://'${MASTER}':9000/test/"|g' ${PERFWORK_DIR}/spark-perf/config/config.py

#Set spark related variables
sed -i 's|SPARK_HOME_DIR = "/root/spark"|SPARK_HOME_DIR = "'${SPARK_HOME}'"|g' ${PERFWORK_DIR}/spark-perf/config/config.py &>>/dev/null
sed -i 's|^SPARK_CLUSTER_URL.*|SPARK_CLUSTER_URL = "yarn"|g' ${PERFWORK_DIR}/spark-perf/config/config.py 
sed -i 's|RESTART_SPARK_CLUSTER = True|RESTART_SPARK_CLUSTER = False|g' ${PERFWORK_DIR}/spark-perf/config/config.py 
sed -i 's|^RSYNC_SPARK_HOME.*|RSYNC_SPARK_HOME = False|g' ${PERFWORK_DIR}/spark-perf/config/config.py 
		
echo "---------------------------------------------" | tee -a $log	


##Setting PREP flag = True for all tests
echo "Setting PREP flag = True for all tests in config.py file" | tee -a $log

sed -i 's|^PREP_SPARK_TESTS.*|PREP_SPARK_TESTS = True|g' ${PERFWORK_DIR}/spark-perf/config/config.py 
sed -i 's|^PREP_PYSPARK_TESTS.*|PREP_PYSPARK_TESTS = True|g' ${PERFWORK_DIR}/spark-perf/config/config.py 
sed -i 's|^PREP_STREAMING_TESTS.*|PREP_STREAMING_TESTS = True|g' ${PERFWORK_DIR}/spark-perf/config/config.py 
sed -i 's|^PREP_MLLIB_TESTS.*|PREP_MLLIB_TESTS = True|g' ${PERFWORK_DIR}/spark-perf/config/config.py 

echo -e
echo 'Please check and if needed, you can edit options like "COMMON_JAVA_OPTS","SPARK_DRIVER_MEMORY","SPARK_KEY_VAL_TEST_OPTS" and other test specific options in file '${PERFWORK_DIR}'/spark-perf/config/config.py'
echo -e
