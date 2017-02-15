
#!/bin/bash -l
echo -e
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

log=${PERFWORK_DIR}/spark_perf_logs/spark_perf_runbench_${current_time}.log

MASTER=`hostname`

echo -e 'Please choose the Y/N option for types of tests you want to run \n'

read -p "Do you wish to run RUN_SPARK_TESTS test ? [y/N] " prompt
if [[ $prompt == "n" || $prompt == "N" ]]
then
    RUN_SPARK_TESTS=False
    echo 'Setting RUN_SPARK_TESTS=False in config.py' | tee -a $log
else 
    RUN_SPARK_TESTS=True
    echo 'Setting RUN_SPARK_TESTS=True in config.py' | tee -a $log
fi
echo -e  | tee -a $log
 
read -p "Do you wish to run RUN_PYSPARK_TESTS test ? [y/N] " prompt
if [[ $prompt == "y" || $prompt == "Y" ]]
then
    RUN_PYSPARK_TESTS=True
    echo 'Setting RUN_PYSPARK_TESTS=True in config.py' | tee -a $log
else 
    RUN_PYSPARK_TESTS=False
    echo 'Setting RUN_PYSPARK_TESTS=False in config.py' | tee -a $log
fi
echo -e  | tee -a $log

 
read -p "Do you wish to run RUN_STREAMING_TESTS test ? [y/N] " prompt
if [[ $prompt == "y" || $prompt == "Y" ]]
then
    RUN_STREAMING_TESTS=True
     
	echo 'Setting RUN_STREAMING_TESTS=True in config.py' | tee -a $log
else 
    RUN_STREAMING_TESTS=False
    echo 'Setting RUN_STREAMING_TESTS=False in config.py' | tee -a $log
fi
echo -e  | tee -a $log
 
read -p "Do you wish to run RUN_MLLIB_TESTS test ? [y/N] " prompt
if [[ $prompt == "y" || $prompt == "Y" ]]
then
    RUN_MLLIB_TESTS=True
    RUN_PYTHON_MLLIB_TESTS=True
	 
	echo 'Setting RUN_MLLIB_TESTS=True and RUN_PYTHON_MLLIB_TESTS=True in config.py'	| tee -a $log
else 
    RUN_MLLIB_TESTS=False
    RUN_PYTHON_MLLIB_TESTS=False
	 
    echo 'Setting RUN_MLLIB_TESTS=False and RUN_PYTHON_MLLIB_TESTS=False in config.py' | tee -a $log
		
fi
echo -e  | tee -a $log
 
SCALE_FACTOR=`grep ^SCALE_FACTOR ${PERFWORK_DIR}/spark-perf/config/config.py | cut -f2 -d "="` 

echo 'Default scaling factor is '${SCALE_FACTOR}''
read -p "Do you wish to change scaling factor? [y/N] " prompt
if [[ $prompt == "y" || $prompt == "Y" ]]
then
    echo "Please enter the value [e.g. - 0.001/0.1/0.25/0.5/0.75]"
    read scale
	SCALE_FACTOR=${scale}
	sed -i 's|^SCALE_FACTOR.*|SCALE_FACTOR = '${SCALE_FACTOR}'|g' ${PERFWORK_DIR}/spark-perf/config/config.py
	 
	echo -e 'Setting SCALE_FACTOR='${scale}' in config.py \n'	| tee -a $log
else 
    echo -e 'Keeping default value '${SCALE_FACTOR}' in config.py \n' | tee -a $log
fi

##Config.py changes

sed -i 's|^RUN_SPARK_TESTS.*|RUN_SPARK_TESTS = '${RUN_SPARK_TESTS}'|g' ${PERFWORK_DIR}/spark-perf/config/config.py 
sed -i 's|^RUN_PYSPARK_TESTS.*|RUN_PYSPARK_TESTS = '${RUN_PYSPARK_TESTS}'|g' ${PERFWORK_DIR}/spark-perf/config/config.py 
sed -i 's|^RUN_STREAMING_TESTS.*|RUN_STREAMING_TESTS = '${RUN_STREAMING_TESTS}'|g' ${PERFWORK_DIR}/spark-perf/config/config.py 
sed -i 's|^RUN_MLLIB_TESTS.*|RUN_MLLIB_TESTS = '${RUN_MLLIB_TESTS}'|g' ${PERFWORK_DIR}/spark-perf/config/config.py 
sed -i 's|RUN_PYTHON_MLLIB_TESTS.*|RUN_PYTHON_MLLIB_TESTS = '${RUN_PYTHON_MLLIB_TESTS}'|g' ${PERFWORK_DIR}/spark-perf/config/config.py 

##setting PROMPT_FOR_DELETES to false
sed -i 's|PROMPT_FOR_DELETES = True|PROMPT_FOR_DELETES = False|g' ${PERFWORK_DIR}/spark-perf/config/config.py 
##Running the spark-perf

cd ${PERFWORK_DIR}/spark-perf
#rm -rf ${PERFWORK_DIR}/spark-perf/results/* &>//dev/null 

echo "Running the spark-perf benchmark" | tee -a $log
#${PERFWORK_DIR}/spark-perf/bin/run | tee -a $log

if [ ! -d ${PERFWORK_DIR}/spark_perf_results ]
then
    mkdir ${PERFWORK_DIR}/spark_perf_results  
fi

echo "---------------------------------------------" | tee -a $log

cd ${PERFWORK_DIR}/spark-perf/results &>//dev/null

zip -r ${PERFWORK_DIR}/spark_perf_results/spark_perf_output_$current_time.zip ./* &>>/dev/null

echo 'Copying results to '${PERFWORK_DIR}'/spark_perf_results/spark_perf_output_'$current_time'.zip' | tee -a $log

##setting back prep flag to false value
if [ ${RUN_SPARK_TESTS} = "True" ]
then
    echo "Setting PREP_SPARK_TESTS=False in config.py"
	sed -i 's|^PREP_SPARK_TESTS.*|PREP_SPARK_TESTS = False|g' ${PERFWORK_DIR}/spark-perf/config/config.py 
fi

if [ ${RUN_PYSPARK_TESTS} = "True" ]
then
    echo "Setting PREP_PYSPARK_TESTS=False in config.py"
	sed -i 's|^PREP_PYSPARK_TESTS.*|PREP_PYSPARK_TESTS = False|g' ${PERFWORK_DIR}/spark-perf/config/config.py 
fi

if [ ${RUN_STREAMING_TESTS} = "True" ]
then
    echo "Setting RUN_STREAMING_TESTS=False in config.py"
	sed -i 's|^PREP_STREAMING_TESTS.*|PREP_STREAMING_TESTS = False|g' ${PERFWORK_DIR}/spark-perf/config/config.py 
fi

if [ ${RUN_MLLIB_TESTS} = "True" ]
then
    echo "Setting PREP_SPARK_TESTS=False in config.py"
	sed -i 's|^PREP_MLLIB_TESTS.*|PREP_MLLIB_TESTS = False|g' ${PERFWORK_DIR}/spark-perf/config/config.py 
fi

echo 'You can check results at '${PERFWORK_DIR}'/spark_perf_results and logs at '${PERFWORK_DIR}'/spark_perf_logs' | tee -a $log
	

