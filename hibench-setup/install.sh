#!/bin/bash -l
echo -e
if [ -z ${WORKDIR} ]; then
   echo "Please set your work directory environment variable - "WORKDIR"." | tee -a $log
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

echo -e 'Node server details for existing hadoop and spark setup' | tee -a $log
MASTER=`hostname`
echo -e 'MASTER='$MASTER'' | tee -a $log

SLAVES=`cat ${HADOOP_CONF_DIR}/slaves | tr '\n' ','| sed 's/\,$//'`
echo -e 'SLAVES='$SLAVES'' | tee -a $log
echo "---------------------------------------------" | tee -a $log


#Hibench git repository url
HIBENCH_GIT_URL='https://github.com/intel-hadoop/HiBench.git'
echo -e 'HIBENCH GIT_URL='$HIBENCH_GIT_URL'' | tee -a $log

echo "---------------------------------------------" | tee -a $log

##Checking if wget and curl installed or not, and getting installed if not for ubuntu and redhat both
python -mplatform  |grep -i redhat >/dev/null 2>&1
# Ubuntu
if [ $? -ne 0 ]
then
	#check for zip installed or not
        is_redhat=0
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
	   sudo apt-get install -y  maven &>> $log
	fi

	if [ ! -x /usr/bin/python ] 
	then
	   echo "Python is not installed on Master, so installing Python" | tee -a $log
	   sudo apt-get install -y python &>> $log  
	fi
else
	#check for zip installed or not
        is_redhat=1
	if [ ! -x /usr/bin/zip ] 
	then
	   echo "zip is not installed on Master, so getting installed" | tee -a $log
	   sudo yum -y install zip &>> $log
	fi

	#check for maven installed or not
    
	mvn_install=0
	mvn -version &>> /dev/null
	if [ $? -ne 0 ]
	then
	    mvn_install=1
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
    git clone --depth 1 --recursive ${HIBENCH_GIT_URL} | tee -a $log
	echo -e 
	echo -e 'HiBench cloning done at - '${HIBENCH_WORK_DIR}'/HiBench' | tee -a $log
				 
else
    echo -e
    echo 'This URL - '${HIBENCH_GIT_URL}' does not exist. Please check url for HiBench git repository.' | tee -a $log
	exit 1
fi 
	
echo "---------------------------------------------" | tee -a $log

##Hadoop config updates
	
cp ${HIBENCH_WORK_DIR}/HiBench/conf/hadoop.conf.template ${HIBENCH_WORK_DIR}/HiBench/conf/hadoop.conf

sed -i 's|^hibench.hadoop.home.*|hibench.hadoop.home    '${HADOOP_HOME}'|g' ${HIBENCH_WORK_DIR}/HiBench/conf/hadoop.conf
sed -i 's|^hibench.hdfs.master.*|hibench.hdfs.master       hdfs://'${MASTER}':9000 |g' ${HIBENCH_WORK_DIR}/HiBench/conf/hadoop.conf

##spark config updates
cp ${HIBENCH_WORK_DIR}/HiBench/conf/spark.conf.template ${HIBENCH_WORK_DIR}/HiBench/conf/spark.conf

sed -i 's|^hibench.spark.home.*|hibench.spark.home    '${SPARK_HOME}'|g' ${HIBENCH_WORK_DIR}/HiBench/conf/spark.conf
sed -i 's|^hibench.spark.master.*|hibench.spark.master    yarn |g' ${HIBENCH_WORK_DIR}/HiBench/conf/spark.conf
echo -e >> ${HIBENCH_WORK_DIR}/HiBench/conf/spark.conf
echo "#spark classpath for mysql jar locations">> ${HIBENCH_WORK_DIR}/HiBench/conf/spark.conf
echo "spark.executor.extraClassPath /usr/share/java/mysql-connector-java.jar" >> ${HIBENCH_WORK_DIR}/HiBench/conf/spark.conf
echo "spark.driver.extraClassPath /usr/share/java/mysql-connector-java.jar" >> ${HIBENCH_WORK_DIR}/HiBench/conf/spark.conf
	
cd ${HIBENCH_WORK_DIR}/HiBench

echo -e "Building HiBench redirecting logs to $log" | tee -a $log

${HIBENCH_WORK_DIR}/HiBench/bin/build-all.sh >> $log
echo -e
echo -e 'Please edit memory and executor related parameters like "hibench.yarn.executor.num","hibench.yarn.executor.cores","spark.executor.memory","spark.driver.memory" as per your requirement in '${HIBENCH_WORK_DIR}'/HiBench/conf/spark.conf file \n'
if [ $is_redhat = 1 ] && [ $mvn_install -ne 0 ]
then
	echo -e 'Please execute "source ~/.bashrc" to export updated maven related environment variables in your current login session. \n'
fi
