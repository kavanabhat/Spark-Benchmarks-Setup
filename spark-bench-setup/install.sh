#!/bin/bash

BASEDIR=$(dirname "$0")
#echo "BASEDIR $BASEDIR"

ABS_PATH=$(pwd)

source $BASEDIR/functions.sh
WORK_DIR=$BASEDIR/wdir

mkdir -p $WORK_DIR
mkdir -p $WORK_DIR/logs

log="$ABS_PATH/$WORK_DIR/logs/install.log"

echo -e 'Node server details for existing hadoop and spark setup' | tee -a $log
MASTER=`hostname`
echo -e 'MASTER='$MASTER'' | tee -a $log

SLAVES=`cat ${HADOOP_CONF_DIR}/slaves | tr '\n' ','| sed 's/\,$//'`
echo -e 'SLAVES='$SLAVES'' | tee -a $log
echo "---------------------------------------------" | tee -a $log


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
	
echo "-----------installing packages---------------" | tee -a $log

packages="git maven git-extras"
for package in $packages 
do
echo "-----------checking $package-----------------" | tee -a $log
	check_package $package $log
echo "---------------------------------------------" | tee -a $log

done


git-ignore $WORK_DIR

cd $WORK_DIR
echo "Cloning necessary dependencies to $WORK_DIR"

git_from_zip https://github.com/synhershko/wikixmlj master wikixmlj | tee -a $log
cd wikixmlj
echo "Building wikixmlj, logs redirected to $log" | tee -a $log
mvn package install >> $log


cd ..
git_from_zip  https://github.com/MaheshIBM/spark-bench spark2.0.1 spark-bench | tee -a $log


cd spark-bench
echo "Building spark bench, logs redirected to $log" | tee -a $log
./bin/build-all.sh >> $log
cp conf/env.sh.template conf/env.sh

#set the master and slaves in conf/evn.sh

echo "---------------------------------------------" | tee -a $log
echo "Setting the slaves for spark-bench script to $SLAVES"  | tee -a $log
echo "Setting the master for spark-bench to $MASTER" | tee -a $log 
echo "---------------------------------------------" | tee -a $log
#replace line 3 with master=`hostname`
sed -i  "3s/.*/master=$MASTER/" conf/env.sh

#replace line 5 with MC_LIST="$SLAVES"
#need to escape spaces for sed to work
MC="\"`cat $HADOOP_HOME/etc/hadoop/slaves`\""
echo $MC
export MC_ESC=$(echo $MC | sed 's/ /\\ /g')
echo $MS_ESC
sed -i  "5s/.*/MC_LIST=$MC_ESC/" conf/env.sh

echo "---------------------------------------------" | tee -a $log
echo "Setting the default run mode to yarn cluster"  | tee -a $log
echo "---------------------------------------------" | tee -a $log
line_number=$(grep -n ^YARN_DEPLOY_MODE= conf/env.sh | awk -F':' '{ print $1 }')
sed -i "$( echo $line_number)s/.*/YARN_DEPLOY_MODE=cluster/" conf/env.sh

echo " *******************************************************
Spark Bench has been successfully set up. 
Check the documentation at Spark-Benchmarks-Setup/spark-bench-setup/README.md on how to run each of the benchmarks.
Logs for installation are located at $log
Logs for benchmark runs will be created at $ABS_PATH/wdir/logs
*******************************************************"
