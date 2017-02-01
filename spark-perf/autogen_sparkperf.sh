#!/bin/bash -l

echo -e '#Master Details' > config.sh
MASTER=`ifconfig | grep "inet" |head -1 | awk {'print $2'} | cut -f2 -d ":"`
echo -e 'MASTER='$MASTER'\n' >> config.sh

echo -e 'Please enter slave IP detail in format slave1IP,slave2IP'
read SLAVEIP

j=0
for i in `echo $SLAVEIP |tr ',' ' '`
do
slaveip=$(ssh $i /sbin/ifconfig | grep "inet" |head -1 | awk {'print $2'} | cut -f2 -d ":")

if [ $j -eq 0 ]
then
SLAVE=${slaveip}
else
SLAVE=`echo ''${SLAVE}'%'${slaveip}''`
fi
((j=j+1))
done

echo -e '#Slave Details' >> config.sh
echo -e 'SLAVES='$SLAVE'\n' >> config.sh

echo -e
echo -n "Please enter Spark version : "
read -n 5 sparkver
echo -e "\nFor Spark Version: $sparkver"
if [ ${sparkver:0:1} == 2 ]
then
  echo -e "Available hadoop versions: 1.2.1, 2.5.2, 2.6.0, 2.6.1, 2.6.2, 2.6.3, 2.6.4, 2.6.5, 2.7.0, 2.7.1, 2.7.2, 2.7.3 "
  echo -e "Please enter Hadoop version (Above versions are compatibility with spark-2.0.0 and later): "
  read -n 5 hadoopver
  echo -e 
elif [ ${sparkver:0:1} -lt 2 ]
then 
  echo -e "available hadoop versions: 1.2.1, 2.5.2, 2.6.0, 2.6.1, 2.6.2, 2.6.3, 2.6.4, 2.6.5 "
  echo -e "Please enter Hadoop version (less than 2.7.0 which are compatibility with below spark-2.0.0) : "
  read -n 5 hadoopver
  echo -e 
fi

echo -e '#Hadoop and Spark versions ' >> config.sh
echo -e 'sparkver='"$sparkver"'' >> config.sh
echo -e 'hadoopver='"$hadoopver"'\n' >> config.sh

echo -e '#Hadoop and Spark setup zip download urls' >> config.sh

HADOOP_URL="http://www-us.apache.org/dist/hadoop/common/hadoop-${hadoopver}/hadoop-${hadoopver}.tar.gz"
SPARK_URL="http://www-us.apache.org/dist/spark/spark-${sparkver}/spark-${sparkver}-bin-hadoop${hadoopver:0:3}.tgz"

echo -e 'SPARK_URL='$SPARK_URL'' >> config.sh
echo -e 'HADOOP_URL='$HADOOP_URL'\n' >> config.sh

echo -e '#spark perf git repository urln' >> config.sh

SPARK_PERF_GIT_URL="https://github.com/a-roberts/spark-perf"

echo -e "SPARK_PERF_GIT_URL='$SPARK_PERF_GIT_URL' \n" >> config.sh

echo -e
echo "Please choose the option for types of tests you want to run"
echo "#Types tests selected to run" >> config.sh
read -p "Do you wish to run RUN_SPARK_TESTS test ? [y/N] " prompt
if [[ $prompt == "n" || $prompt == "N" ]]
then
    echo -e 'RUN_SPARK_TESTS=False' >> config.sh
    echo -e 'PREP_SPARK_TESTS=False' >> config.sh
else 
    echo -e 'RUN_SPARK_TESTS=True' >> config.sh
    echo -e 'PREP_SPARK_TESTS=True' >> config.sh
fi
echo -e >> config.sh
read -p "Do you wish to run RUN_PYSPARK_TESTS test ? [y/N] " prompt
if [[ $prompt == "y" || $prompt == "Y" ]]
then
    echo -e 'RUN_PYSPARK_TESTS=True' >> config.sh
    echo -e 'PREP_PYSPARK_TESTS=True' >> config.sh
else 
    echo -e 'RUN_PYSPARK_TESTS=False' >> config.sh
    echo -e 'PREP_PYSPARK_TESTS=False' >> config.sh
fi
echo -e >> config.sh
read -p "Do you wish to run RUN_STREAMING_TESTS test ? [y/N] " prompt
if [[ $prompt == "y" || $prompt == "Y" ]]
then
    echo -e 'RUN_STREAMING_TESTS=True' >> config.sh
    echo -e 'PREP_STREAMING_TESTS=True' >> config.sh
else 
    echo -e 'RUN_STREAMING_TESTS=False' >> config.sh
    echo -e 'PREP_STREAMING_TESTS=False' >> config.sh	
fi
echo -e >> config.sh
read -p "Do you wish to run RUN_MLLIB_TESTS test ? [y/N] " prompt
if [[ $prompt == "y" || $prompt == "Y" ]]
then
    echo -e 'RUN_MLLIB_TESTS=True' >> config.sh
    echo -e 'PREP_MLLIB_TESTS=True' >> config.sh
	echo -e 'RUN_PYTHON_MLLIB_TESTS=True' >> config.sh
else 
    echo -e 'RUN_MLLIB_TESTS=False' >> config.sh
    echo -e 'PREP_MLLIB_TESTS=False' >> config.sh
	echo -e 'RUN_PYTHON_MLLIB_TESTS=False' >> config.sh	
		
fi

echo -e >> config.sh
echo -e
echo "#Scale Factor selected for run" >> config.sh
read -p "Do you wish to change scaling factor? [y/N] " prompt
if [[ $prompt == "y" || $prompt == "Y" ]]
then
    echo "Please enter the value [0.001/0.1/0.25/0.5/0.75] "
    read scale
	echo -e 'SCALE_FACTOR='${scale}'' >> config.sh
else 
    scale=1
	echo -e 'SCALE_FACTOR='${scale}'' >> config.sh
fi

echo -e 'Please check configuration (config.sh file) once before run (setup.sh file).'
echo -e 'You can modify hadoop or spark versions in config.sh file'
echo -e
chmod +x config.sh

