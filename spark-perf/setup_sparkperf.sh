#!/bin/bash -l

CURDIR=`pwd`            
WORKDIR=${HOME}   

current_time=$(date +"%Y.%m.%d.%S")

if [ ! -d spark_perf_logs ];
then
    mkdir spark_perf_logs
fi

log=`pwd`/spark_perf_logs/spark_perf_$current_time.log

echo -e | tee -a $log

#check for prerequisites

#Checking if JAVA_HOME set
if [[ -n "$JAVA_HOME" ]] && [[ -x "$JAVA_HOME/bin/java" ]]
then
    echo JAVA_HOME found on MASTER, java executable in $JAVA_HOME | tee $log
    echo "---------------------------------------------" | tee -a $log
else
    echo "JAVA_HOME not found in your environment, please set the JAVA_HOME variable in your environment then continue to run this script." | tee -a $log
    exit 1 
fi

#Checking if below line commented in .bashrc
grep '#case $- in' $HOME/.bashrc &>>/dev/null
 if [ $? -ne 0 ]
then
    grep 'case $- in' $HOME/.bashrc &>>/dev/null
	if [ $? -eq 0 ]
	then 
        echo 'Prerequisite not completed on Master. Please comment below lines in .bashrc file , also make sure same on slave machines' | tee -a $log
        echo "# If not running interactively, don't do anything" | tee -a $log
        echo "case \$- in" | tee -a $log
        echo "*i*) ;;" | tee -a $log
        echo "*) return;;" | tee -a $log
        echo "esac" | tee -a $log
	    exit 1
	fi	
fi

##Checking if wget and curl installed or not, and getting installed if not

if [ ! -x /usr/bin/wget ] ; then
   echo "wget is not installed on Master, so getting installed" | tee -a $log
   sudo apt-get install wget | tee -a $log
else
   echo "wget is already installed on Master" | tee -a $log
fi

if [ ! -x /usr/bin/curl ] ; then
   echo "curl is not installed on Master, so getting installed" | tee -a $log
   sudo apt-get install curl | tee -a $log
else
   echo "curl is already installed on Master" | tee -a $log
fi

#checking if config.sh file is created in required format

if [ -f ${CURDIR}/config.sh ]; 
then
    ## First time permission set for config.sh file
    chmod +x ${CURDIR}/config.sh
    source ${CURDIR}/config.sh
 
    ## Checking config file for all required fields
  
    { cat ${CURDIR}/config.sh; echo; } | while read -r line; do
      if [[ $line =~ "=" ]] ;
      then
          confvalue=`echo $line |grep = | cut -d "=" -f2`
          if [[ -z "$confvalue" ]];
          then
              echo "Configuration value not set properly for $line, please check config.sh file" | tee -a $log
              exit 1
          fi
      fi
    done
	
	SERVERS=$SLAVES
	
	cd ${WORKDIR}
	
	# Spark setup steps
    if [ ! -f ${WORKDIR}/spark-${sparkver}-bin-hadoop${hadoopver:0:3}.tgz ];
    then
        if curl --output /dev/null --silent --head --fail $SPARK_URL
        then
	        echo 'SPARK file Downloading on Master - '$MASTER'' | tee -a $log
            wget $SPARK_URL | tee -a $log
        else 
            echo 'This URL '${SPARK_URL}' does not exist. Please check your spark version then continue to run this script.' | tee -a $log
        exit 1
        fi 
	 
    echo "***********************************************"
    fi
	
	for i in `echo $SERVERS | tr "%" "\n"`
    do
		if [ $i != $MASTER ]
		then
			echo 'Copying Spark setup file on '$i'' | tee -a $log
			scp ${WORKDIR}/spark-${sparkver}-bin-hadoop${hadoopver:0:3}.tgz @$i:${WORKDIR} | tee -a $log
	    fi
		
		echo 'Unzipping Spark setup file on '$i'' | tee -a $log
		ssh $i "tar xf spark-${sparkver}-bin-hadoop${hadoopver:0:3}.tgz --gzip" | tee -a $log	
		
		echo 'Updating .bashrc file on '$i' with Spark variables '	
		echo '#StartSparkEnv' >tmp_b
		echo "export SPARK_HOME="${WORKDIR}"/spark-${sparkver}-bin-hadoop${hadoopver:0:3}" >>tmp_b
		echo "export PATH=\$SPARK_HOME/bin:\$PATH">>tmp_b
		echo '#StopSparkEnv'>>tmp_b
			
		scp tmp_b @$i:${WORKDIR}&>>/dev/null
			
		ssh $i "grep -q "SPARK_HOME" ~/.bashrc"
		if [ $? -ne 0 ];
		then
			ssh $i "cat tmp_b>>$HOME/.bashrc"
			ssh $i "rm tmp_b"
		else
			ssh $i "sed -i '/#StartSparkEnv/,/#StopSparkEnv/ d' $HOME/.bashrc"
			ssh $i "cat tmp_b>>$HOME/.bashrc"
			ssh $i "rm tmp_b"
		fi

		ssh $i "source $HOME/.bashrc"
		
	done
	rm -rf tmp_b
	echo "---------------------------------------------" | tee -a $log
	

	## updating Slave file for Spark folder
	source ${HOME}/.bashrc
	echo 'Updating Slave file for Spark setup'| tee -a $log

	cp ${SPARK_HOME}/conf/slaves.template ${SPARK_HOME}/conf/slaves
	sed -i 's|localhost||g' ${SPARK_HOME}/conf/slaves
	
    for i in `echo $SERVERS | tr "%" "\n"`
    do
	  echo ${i} >>${SPARK_HOME}/conf/slaves
	done
	
	echo "---------------------------------------------" | tee -a $log
	
	#SPARK perf setup steps

	if [ ! -d ${WORKDIR}/spark-perf ];
	then
		 if curl --output /dev/null --silent --head --fail ${SPARK_PERF_GIT_URL}
		 then
			 git clone ${SPARK_PERF_GIT_URL} | tee -a $log
			 echo "spark-perf cloning Done" | tee -a $log
				 
		 else
			 echo 'This URL - '${SPARK_PERF_GIT_URL}' does not exist. Please check your url for Spark perf git repository.' | tee -a $log
			 exit 1
		 fi 
	fi

	echo "Sourcing .bashrc file on localhost" | tee -a $log 
	source $HOME/.bashrc
	
	#Config.py changes 

	echo "Configuring changes in config.py file" | tee -a $log
	cp ${WORKDIR}/spark-perf/config/config.py.template ${WORKDIR}/spark-perf/config/config.py
	#Set spark home directory
	sed -i 's|^DEFAULT_HOME.*|DEFAULT_HOME="'${SPARK_HOME}'"|g' ${WORKDIR}/spark-perf/config/config.py
	
	#Set Spark master
	#sed -i 's|^SPARK_CLUSTER_URL.*|SPARK_CLUSTER_URL = "spark://%s:7077" % socket.gethostname()|g' ${WORKDIR}/spark-perf/config/config.py
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

echo "---------------------------------------------" | tee -a $log
echo "Copying results to RESULT directory in home"
if [ ! -d ${HOME}/RESULT ];
then
    mkdir ${HOME}/RESULT
fi

cp -r ${WORKDIR}/spark-perf/results/* ${HOME}/RESULT/.
	

