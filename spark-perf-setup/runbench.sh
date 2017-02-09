
#!/bin/bash -l
echo -e
PERFUTILS_DIR=`pwd`            

current_time=$(date +"%Y.%m.%d.%S")

log=${PERFUTILS_DIR}/spark_perf_logs/spark_perf_runbench_${current_time}.log

MASTER=`hostname`

echo -e 'Please choose the Y/N option for types of tests you want to run \n'

read -p "Do you wish to run RUN_SPARK_TESTS test ? [y/N] " prompt
if [[ $prompt == "n" || $prompt == "N" ]]
then
    RUN_SPARK_TESTS=False
    PREP_SPARK_TESTS=False
	 
	echo 'Setting RUN_SPARK_TESTS=False and PREP_SPARK_TESTS=False in config.py' | tee -a $log
else 
    RUN_SPARK_TESTS=True
    PREP_SPARK_TESTS=True
	 
	echo 'Setting RUN_SPARK_TESTS=True and PREP_SPARK_TESTS=True in config.py' | tee -a $log

fi
echo -e  | tee -a $log
 
read -p "Do you wish to run RUN_PYSPARK_TESTS test ? [y/N] " prompt
if [[ $prompt == "y" || $prompt == "Y" ]]
then
    RUN_PYSPARK_TESTS=True
    PREP_PYSPARK_TESTS=True
	 
	echo 'Setting RUN_PYSPARK_TESTS=True and PREP_PYSPARK_TESTS=True in config.py' | tee -a $log
else 
    RUN_PYSPARK_TESTS=False
    PREP_PYSPARK_TESTS=False
	 
	echo 'Setting RUN_PYSPARK_TESTS=False and PREP_PYSPARK_TESTS=False in config.py' | tee -a $log
fi
echo -e  | tee -a $log

 
read -p "Do you wish to run RUN_STREAMING_TESTS test ? [y/N] " prompt
if [[ $prompt == "y" || $prompt == "Y" ]]
then
    RUN_STREAMING_TESTS=True
    PREP_STREAMING_TESTS=True
	 
	echo 'Setting RUN_STREAMING_TESTS=True and PREP_STREAMING_TESTS=True in config.py' | tee -a $log
else 
    RUN_STREAMING_TESTS=False
    PREP_STREAMING_TESTS=False	
	 
	echo 'Setting RUN_STREAMING_TESTS=False and PREP_STREAMING_TESTS=False in config.py' | tee -a $log
fi
echo -e  | tee -a $log
 
read -p "Do you wish to run RUN_MLLIB_TESTS test ? [y/N] " prompt
if [[ $prompt == "y" || $prompt == "Y" ]]
then
    RUN_MLLIB_TESTS=True
    PREP_MLLIB_TESTS=True
	RUN_PYTHON_MLLIB_TESTS=True
	 
	echo 'Setting RUN_MLLIB_TESTS=True ,PREP_MLLIB_TESTS=True and RUN_PYTHON_MLLIB_TESTS=True in config.py'	| tee -a $log
else 
    RUN_MLLIB_TESTS=False
    PREP_MLLIB_TESTS=False
	RUN_PYTHON_MLLIB_TESTS=False
	 
    echo 'Setting RUN_MLLIB_TESTS=False ,PREP_MLLIB_TESTS=False and RUN_PYTHON_MLLIB_TESTS=False in config.py' | tee -a $log
		
fi
echo -e  | tee -a $log
 

read -p "Do you wish to change scaling factor? [y/N] " prompt
if [[ $prompt == "y" || $prompt == "Y" ]]
then
    echo "Please enter the value [e.g. - 0.001/0.1/0.25/0.5/0.75]"
    read scale
	SCALE_FACTOR=${scale}
	 
	echo -e 'Setting SCALE_FACTOR='${scale}' in config.py \n'	| tee -a $log
else 
    SCALE_FACTOR=1
	 
	echo -e 'Setting SCALE_FACTOR=1 in config.py \n' | tee -a $log
fi

##Config.py changes

sed -i 's|^RUN_SPARK_TESTS.*|RUN_SPARK_TESTS = '${RUN_SPARK_TESTS}'|g' ${PERFUTILS_DIR}/spark-perf/config/config.py 
sed -i 's|^PREP_SPARK_TESTS.*|PREP_SPARK_TESTS = '${PREP_SPARK_TESTS}'|g' ${PERFUTILS_DIR}/spark-perf/config/config.py 

sed -i 's|^RUN_PYSPARK_TESTS.*|RUN_PYSPARK_TESTS = '${RUN_PYSPARK_TESTS}'|g' ${PERFUTILS_DIR}/spark-perf/config/config.py 
sed -i 's|PREP_PYSPARK_TESTS.*|PREP_PYSPARK_TESTS = '${PREP_PYSPARK_TESTS}'|g' ${PERFUTILS_DIR}/spark-perf/config/config.py 

sed -i 's|RUN_STREAMING_TESTS.*|RUN_STREAMING_TESTS = '${RUN_STREAMING_TESTS}'|g' ${PERFUTILS_DIR}/spark-perf/config/config.py 
sed -i 's|PREP_STREAMING_TESTS.*|PREP_STREAMING_TESTS = '${PREP_STREAMING_TESTS}'|g' ${PERFUTILS_DIR}/spark-perf/config/config.py 

sed -i 's|RUN_MLLIB_TESTS.*|RUN_MLLIB_TESTS = '${RUN_MLLIB_TESTS}'|g' ${PERFUTILS_DIR}/spark-perf/config/config.py 
sed -i 's|PREP_MLLIB_TESTS.*|PREP_MLLIB_TESTS = '${PREP_MLLIB_TESTS}'|g' ${PERFUTILS_DIR}/spark-perf/config/config.py 
sed -i 's|RUN_PYTHON_MLLIB_TESTS.*|RUN_PYTHON_MLLIB_TESTS = '${RUN_PYTHON_MLLIB_TESTS}'|g' ${PERFUTILS_DIR}/spark-perf/config/config.py 

sed -i 's|^SCALE_FACTOR.*|SCALE_FACTOR = '${SCALE_FACTOR}'|g' ${PERFUTILS_DIR}/spark-perf/config/config.py
##Running the spark-perf

cd ${PERFUTILS_DIR}/spark-perf
rm -rf ${PERFUTILS_DIR}/spark-perf/results/* &>//dev/null 
echo "Running the spark-perf benchmark" | tee -a $log
${PERFUTILS_DIR}/spark-perf/bin/run | tee -a $log

if [ ! -d ${PERFUTILS_DIR}/spark_perf_results ]
then
    mkdir ${PERFUTILS_DIR}/spark_perf_results  
fi

echo "---------------------------------------------" | tee -a $log

cd ${PERFUTILS_DIR}/spark-perf/results &>//dev/null
current_time=$(date +"%Y.%m.%d.%S")
zip -r ${PERFUTILS_DIR}/spark_perf_results/spark_perf_output_$current_time.zip ./* &>>/dev/null

echo 'Copying results to '${PERFUTILS_DIR}'/spark_perf_results/spark_perf_output_'$current_time'.zip' | tee -a $log
echo 'You can check results at '${PERFUTILS_DIR}'/spark_perf_results and logs at '${PERFUTILS_DIR}'/spark_perf_logs' | tee -a $log
	

