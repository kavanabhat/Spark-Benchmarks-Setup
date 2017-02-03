#!/bin/bash -l

echo -e 'Node server details for existing hadoop and spark setup \n' 
echo -e '#Master details' > config
MASTER=`hostname`
echo -e 'MASTER='$MASTER'' | tee -a config

echo -e '#Slave details of existing hadoop and spark setup' >> config
SLAVES=`cat ${HADOOP_CONF_DIR}/slaves | tr '\n' ','| sed 's/\,$//'`

echo -e 'SLAVES='$SLAVES'' | tee -a config

echo -e '#spark perf git repository url' >> config

sparkversion=`echo $SPARK_HOME | cut -f2 -d "=" | cut -f4 -d "/" | cut -f2 -d "-"` 2>/dev/null

if [ ${sparkversion:0:1} == 2 ]
then
	SPARK_PERF_GIT_URL="https://github.com/a-roberts/spark-perf"
    echo -e 'SPARK_PERF_GIT_URL='$SPARK_PERF_GIT_URL' \n' >> config
else
    
	SPARK_PERF_GIT_URL="https://github.com/databricks/spark-perf.git"
    echo -e 'SPARK_PERF_GIT_URL='$SPARK_PERF_GIT_URL' \n' >> config 
fi

echo -e
echo "Please choose the Y/N option for types of tests you want to run"
echo "#Types of tests selected to run" >> config
read -p "Do you wish to run RUN_SPARK_TESTS test ? [y/N] " prompt
if [[ $prompt == "n" || $prompt == "N" ]]
then
    echo -e 'RUN_SPARK_TESTS=False' >> config
    echo -e 'PREP_SPARK_TESTS=False' >> config
else 
    echo -e 'RUN_SPARK_TESTS=True' >> config
    echo -e 'PREP_SPARK_TESTS=True' >> config
fi

echo -e >> config
read -p "Do you wish to run RUN_PYSPARK_TESTS test ? [y/N] " prompt
if [[ $prompt == "y" || $prompt == "Y" ]]
then
    echo -e 'RUN_PYSPARK_TESTS=True' >> config
    echo -e 'PREP_PYSPARK_TESTS=True' >> config
else 
    echo -e 'RUN_PYSPARK_TESTS=False' >> config
    echo -e 'PREP_PYSPARK_TESTS=False' >> config
fi

echo -e >> config
read -p "Do you wish to run RUN_STREAMING_TESTS test ? [y/N] " prompt
if [[ $prompt == "y" || $prompt == "Y" ]]
then
    echo -e 'RUN_STREAMING_TESTS=True' >> config
    echo -e 'PREP_STREAMING_TESTS=True' >> config
else 
    echo -e 'RUN_STREAMING_TESTS=False' >> config
    echo -e 'PREP_STREAMING_TESTS=False' >> config	
fi

echo -e >> config
read -p "Do you wish to run RUN_MLLIB_TESTS test ? [y/N] " prompt
if [[ $prompt == "y" || $prompt == "Y" ]]
then
    echo -e 'RUN_MLLIB_TESTS=True' >> config
    echo -e 'PREP_MLLIB_TESTS=True' >> config
	echo -e 'RUN_PYTHON_MLLIB_TESTS=True' >> config
else 
    echo -e 'RUN_MLLIB_TESTS=False' >> config
    echo -e 'PREP_MLLIB_TESTS=False' >> config
	echo -e 'RUN_PYTHON_MLLIB_TESTS=False' >> config	
		
fi

echo -e >> config
echo -e

echo "#Scale Factor selected for run" >> config
read -p "Do you wish to change scaling factor? [y/N] " prompt
if [[ $prompt == "y" || $prompt == "Y" ]]
then
    echo "Please enter the value [e.g. - 0.001/0.1/0.25/0.5/0.75]"
    read scale
	echo -e 'SCALE_FACTOR='${scale}'' >> config
else 
    scale=1
	echo -e 'SCALE_FACTOR='${scale}'' >> config
fi

echo -e 'Please check configuration (config file) once before run (setup_sparkperf.sh file).'
echo -e 'You can modify selected values in config file.'
echo -e
chmod +x config