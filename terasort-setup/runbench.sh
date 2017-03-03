#!/bin/bash -l
echo -e
if [ -z ${WORKDIR} ]; then
   echo "Please set your work directory environment variable - "WORKDIR"." | tee -a $log
   exit 1
fi

TERASORT_UTILS_DIR=$WORKDIR/Spark-Benchmarks-Setup/terasort-setup  
current_time=$(date +"%Y.%m.%d.%S")

if [ ! -d ${TERASORT_UTILS_DIR}/wdir ];
then
    mkdir ${TERASORT_UTILS_DIR}/wdir
fi

TERASORT_WORK_DIR=$WORKDIR/Spark-Benchmarks-Setup/terasort-setup/wdir

if [ ! -d ${TERASORT_WORK_DIR}/terasort_logs ];
then
    mkdir ${TERASORT_WORK_DIR}/terasort_logs
fi

log=${TERASORT_WORK_DIR}/terasort_logs/terasort_runbench_$current_time.log


cd ${SPARK_HOME}

MASTER=`hostname`
SLAVES=`cat ${HADOOP_CONF_DIR}/slaves | tr '\n' ','| sed 's/\,$//'`

echo "Generating Data"| tee -a $log

${SPARK_HOME}/bin/spark-submit --class com.github.ehiggs.spark.terasort.TeraGen ${TERASORT_WORK_DIR}/spark-terasort/target/spark-terasort-1.0-jar-with-dependencies.jar 1G hdfs://${MASTER}:9000/data/terasort_in | tee -a $log

echo -e | tee -a $log
echo "Sorting Data" | tee -a $log

${SPARK_HOME}/bin/spark-submit --conf 'spark.executor.extraJavaOptions=-Dos.arch=ppc64le' --master yarn-client --class com.github.ehiggs.spark.terasort.TeraSort ${TERASORT_WORK_DIR}/spark-terasort/target/spark-terasort-1.0-jar-with-dependencies.jar hdfs://${MASTER}:9000/data/terasort_in hdfs://${MASTER}:9000/data/terasort_out | tee -a $log

echo "---------------------------------------------" | tee -a $log

rm -rf ${TERASORT_UTILS_DIR}/wdir/spark-terasort/output &>>/dev/null

mkdir ${TERASORT_UTILS_DIR}/wdir/spark-terasort/output

for slave in `echo $SLAVES |cut -d "=" -f2 | tr "," "\n" | cut -d "," -f1`
do
echo -e '\nValidating Data on '$slave'' | tee -a $log

${SPARK_HOME}/bin/spark-submit --conf 'spark.executor.extraJavaOptions=-Dos.arch=ppc64le' --master yarn-client --class com.github.ehiggs.spark.terasort.TeraValidate ${TERASORT_WORK_DIR}/spark-terasort/target/spark-terasort-1.0-jar-with-dependencies.jar hdfs://${MASTER}:9000/data/terasort_out hdfs://${slave}:9000/data/terasort_validate | tee -a ${TERASORT_UTILS_DIR}/wdir/spark-terasort/output/Validate_result_${slave}

done

if [ ! -d ${TERASORT_WORK_DIR}/terasort_results ];
then
    mkdir ${TERASORT_WORK_DIR}/terasort_results
fi

cd ${TERASORT_UTILS_DIR}/wdir/spark-terasort/output

zip -r ${TERASORT_WORK_DIR}/terasort_results/terasort_output_$current_time.zip ./* &>>/dev/null

echo -e '\nYou can check results at location '${TERASORT_WORK_DIR}'/terasort_results and logs at location '${TERASORT_WORK_DIR}'/terasort_logs' | tee -a $log


