#!/bin/bash -l

PERFUTILS_DIR=`pwd`            
WORKDIR=${HOME}   

current_time=$(date +"%Y.%m.%d.%S")

if [ ! -d ${PERFUTILS_DIR}/spark_perf_logs ];
then
    mkdir ${PERFUTILS_DIR}/spark_perf_logs
fi

log=${PERFUTILS_DIR}/spark_perf_logs/spark_perf_$current_time.log

echo -e | tee -a $log

#check for zip installed or not
if [ ! -x /usr/bin/zip ] ; then
   echo "zip is not installed on Master, so getting installed" | tee -a $log
   sudo apt-get install zip | tee -a $log
fi

#checking if config file is created in required format

if [ -f ${PERFUTILS_DIR}/config ]; 
then
    ## First time permission set for config file
    chmod +x ${PERFUTILS_DIR}/config
    source ${PERFUTILS_DIR}/config
 
    ## Checking config file for all required fields
  
    { cat ${PERFUTILS_DIR}/config; echo; } | while read -r line; do
      if [[ $line =~ "=" ]] ;
      then
          confvalue=`echo $line |grep = | cut -d "=" -f2`
          if [[ -z "$confvalue" ]];
          then
              echo "Configuration value not set properly for $line, please check config file" | tee -a $log
              exit 1
          fi
      fi
    done
	
	#check if atleast 1 type of test is selected
	grep "_TEST" ${PERFUTILS_DIR}/config | grep "=True" &>>/dev/null
	if [ $? -ne 0 ]
	then
	    echo 'Please selct atleast one type of test to run spark-perf benchamrk' | tee -a $log
		exit 1
	fi
	
	#Logic to create server list 
    cat ${PERFUTILS_DIR}/config | grep SLAVES | grep -v "^#" | tr "," "\n" | grep "$MASTER" &>>/dev/null
    if [ $? -eq 0 ]
    then
	    #if master is also used as data machine 
        SERVERS=$SLAVES
    else
        SERVERS=`echo ''$MASTER'%'$SLAVES''`
    fi
		
	cd ${WORKDIR}
	
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
		SPARK=$(ssh $i "grep '^export SPARK_HOME' $HOME/.bashrc | cut -f2 -d "="") 2>/dev/null
		if [[ $? -eq 0 ]]
		then
			echo -e 'SPARK setup found on '$i' at '$SPARK'' | tee -a $log
		else
			echo -e 'SPARK setup not found on '$i', Please complete spark setup using hadoop-cluster-utils.' | tee -a $log
			exit 1 
		fi
	done
	
	echo "---------------------------------------------" | tee -a $log
	
	##SPARK perf setup steps

	if [ -d ${WORKDIR}/spark-perf ];
	then
	    echo -e 'Removing existing spark-perf folder - '${WORKDIR}'/spark-perf \n' | tee -a $log
		rm -rf ${WORKDIR}/spark-perf &>/dev/null
	fi
	
    if curl --output /dev/null --silent --head --fail ${SPARK_PERF_GIT_URL}
	then
		 git clone ${SPARK_PERF_GIT_URL} | tee -a $log
		 echo -e 
		 echo -e 'spark-perf cloning done at - '${WORKDIR}'/spark-perf' | tee -a $log
				 
	else
	     echo -e
		 echo 'This URL - '${SPARK_PERF_GIT_URL}' does not exist. Please check url for Spark perf git repository.' | tee -a $log
		 exit 1
	fi 
	
    echo "---------------------------------------------" | tee -a $log
	
	source $HOME/.bashrc
	##Config.py changes 

	echo "Configuring changes in config.py file" | tee -a $log
	cp ${WORKDIR}/spark-perf/config/config.py.template ${WORKDIR}/spark-perf/config/config.py 
	#Set spark home directory
	sed -i 's|^DEFAULT_HOME.*|DEFAULT_HOME="'${SPARK_HOME}'"|g' ${WORKDIR}/spark-perf/config/config.py 
	sed -i 's|SPARK_HOME_DIR = "/root/spark"|SPARK_HOME_DIR = "'${SPARK_HOME}'"|g' ${WORKDIR}/spark-perf/config/config.py 
	#Set Spark master
	sed -i 's|^SPARK_CLUSTER_URL.*|SPARK_CLUSTER_URL = "spark://'${HOSTNAME}':7077"|g' ${WORKDIR}/spark-perf/config/config.py 
	
	sed -i 's|^RUN_SPARK_TESTS.*|RUN_SPARK_TESTS = '${RUN_SPARK_TESTS}'|g' ${WORKDIR}/spark-perf/config/config.py 
	sed -i 's|^PREP_SPARK_TESTS.*|PREP_SPARK_TESTS = '${PREP_SPARK_TESTS}'|g' ${WORKDIR}/spark-perf/config/config.py 

	sed -i 's|^RUN_PYSPARK_TESTS.*|RUN_PYSPARK_TESTS = '${RUN_PYSPARK_TESTS}'|g' ${WORKDIR}/spark-perf/config/config.py 
	sed -i 's|PREP_PYSPARK_TESTS.*|PREP_PYSPARK_TESTS = '${PREP_PYSPARK_TESTS}'|g' ${WORKDIR}/spark-perf/config/config.py 

	sed -i 's|RUN_STREAMING_TESTS.*|RUN_STREAMING_TESTS = '${RUN_STREAMING_TESTS}'|g' ${WORKDIR}/spark-perf/config/config.py 
	sed -i 's|PREP_STREAMING_TESTS.*|PREP_STREAMING_TESTS = '${PREP_STREAMING_TESTS}'|g' ${WORKDIR}/spark-perf/config/config.py 

	sed -i 's|RUN_MLLIB_TESTS.*|RUN_MLLIB_TESTS = '${RUN_MLLIB_TESTS}'|g' ${WORKDIR}/spark-perf/config/config.py 
	sed -i 's|PREP_MLLIB_TESTS.*|PREP_MLLIB_TESTS = '${PREP_MLLIB_TESTS}'|g' ${WORKDIR}/spark-perf/config/config.py 
	sed -i 's|RUN_PYTHON_MLLIB_TESTS.*|RUN_PYTHON_MLLIB_TESTS = '${RUN_PYTHON_MLLIB_TESTS}'|g' ${WORKDIR}/spark-perf/config/config.py 

	sed -i 's|^SCALE_FACTOR.*|SCALE_FACTOR = '${SCALE_FACTOR}'|g' ${WORKDIR}/spark-perf/config/config.py 
else
    echo "Config file does not exist. Please check README.md for installation steps." | tee -a $log
    exit 1
fi

echo "---------------------------------------------" | tee -a $log	

cd ${WORKDIR}/spark-perf

#Running the spark-perf
echo "Running the spark-perf benchmark" | tee -a $log
${WORKDIR}/spark-perf/bin/run | tee -a $log

if [ ! -d ${PERFUTILS_DIR}/spark_perf_results ]
then
    mkdir ${PERFUTILS_DIR}/spark_perf_results  
fi

echo "---------------------------------------------" | tee -a $log

cd ${WORKDIR}/spark-perf/results &>//dev/null
current_time=$(date +"%Y.%m.%d.%S")
zip -r ${PERFUTILS_DIR}/spark_perf_results/spark_perf_output_$current_time.zip ./* &>>/dev/null

echo 'Copying results to '${PERFUTILS_DIR}'/spark_perf_results/spark_perf_output_'$current_time'.zip' | tee -a $log
echo 'You can check results at location '${PERFUTILS_DIR}'/spark_perf_results and logs at location '${PERFUTILS_DIR}'/spark_perf_logs' | tee -a $log
	

