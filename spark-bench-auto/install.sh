#!/bin/bash

source functions.sh


packages="git maven git-extras"
for package in $packages 
do
	check_package $package
done

export SLAVES=`cat $HADOOP_HOME/etc/hadoop/slaves`



#SPARK_BENCH_INSTALL_DIR="/home/hdp_test/test_install"

#if [ -z $SPARK_BENCH_INSTALL_DIR ]; then
#    echo "Spark bench home not set, setting to /home/`whoami`"
#    SPARK_BENCH_INSTALL_DIR="/home/`whoami`"
#else
#    echo "Spark bench home set to $SPARK_BENCH_INSTALL_DIR"
#fi

#echo $SPARK_BENCH_INSTALL_DIR
#mkdir -p $SPARK_BENCH_INSTALL_DIR
#cd $SPARK_BENCH_INSTALL_DIR


git clone https://github.com/synhershko/wikixmlj.git
cd wikixmlj
mvn package install

gitignore wikixmlj

cd ..
git clone https://github.com/MaheshIBM/spark-bench -b spark2.0.1

gitingore spark-bench

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

