#!/bin/bash

BASEDIR=$(dirname "$0")
#echo "$BASEDIR"

source $BASEDIR/functions.sh


packages="git maven git-extras"
for package in $packages 
do
	check_package $package
done

export SLAVES=`cat $HADOOP_HOME/etc/hadoop/slaves`



WORK_DIR=$BASEDIR/wdir

mkdir -p $WORK_DIR

git-ignore $WORK_DIR

cd $WORK_DIR
echo "Cloning necessary dependencies to $WORK_DIR"

git clone https://github.com/synhershko/wikixmlj.git
cd wikixmlj
mvn package install


cd ..
git clone https://github.com/MaheshIBM/spark-bench -b spark2.0.1


cd spark-bench
./bin/build-all.sh
cp conf/env.sh.template conf/env.sh

#set the master and slaves in conf/evn.sh

MC="\"`cat $HADOOP_HOME/etc/hadoop/slaves`\""
echo "Setting the slaves for spark-bench script to $MC"

MASTER=\"`hostname`\"
echo "Setting the master for spark-bench to $MASTER"

#replace line 3 with master=`hostname`
sed -i  "3s/.*/master=$MASTER/" conf/env.sh

#replace line 5 with MC_LIST="$SLAVES"
#need to escape spaces for sed to work
export MC_ESC=$(echo $MC | sed 's/ /\\ /g')
sed -i  "5s/.*/MC_LIST=$MC_ESC/" conf/env.sh

echo "Spark Bench has been successfully set up \n
Check the documentation at /Spark-Benchmarks-Setup/spark-bench-auto/README.md on how to run each of the benchmarks"
