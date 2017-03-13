#!/bin/bash -l

display_usage() { 
	echo "Usage: ./runbench.sh -cvs <data_size>" 
        echo "-c : create data, data_size is required here for example 1G"
        echo "-s : sort workload"
        echo "-v : validate results" 
        echo "Examples: ./runbench.sh -cvs 1G"
        echo "          ./runbench.sh -vs "
       
}
 
if [ $# -eq 0 ]
  then
    display_usage
    exit 1
  fi

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

CREATE_DATA=0
RUN=0
VALIDATE=0
SORT=0
while getopts "cvs" opt; do
  case $opt in
    c)
      CREATE_DATA=1
      ;;
    s)
      SORT=1
      ;;
    v)
      VALIDATE=1
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      display_usage
      exit 1
      ;;
  esac
done

DATA_SIZE="${@: -1}"
if [ $# -le 1 ] && [ $CREATE_DATA = 1 ]
then 
    echo "Please specify data size when using -c (create) flag"
    display_usage
    exit 1
fi 

echo "Log file created at $log"

if [ $CREATE_DATA -eq 1 ]
then
    echo "Creating Data of size ${DATA_SIZE} "| tee -a $log
    ${SPARK_HOME}/bin/spark-submit --class com.github.ehiggs.spark.terasort.TeraGen ${TERASORT_WORK_DIR}/spark-terasort/target/spark-terasort-1.0-jar-with-dependencies.jar ${DATA_SIZE} hdfs://${MASTER}:9000/data/terasort_in | tee -a $log

fi

echo -e | tee -a $log

if [ $SORT -eq 1 ]
then
    echo "Sorting Data" | tee -a $log

    ${SPARK_HOME}/bin/spark-submit --conf 'spark.executor.extraJavaOptions=-Dos.arch=ppc64le' --master yarn --class com.github.ehiggs.spark.terasort.TeraSort ${TERASORT_WORK_DIR}/spark-terasort/target/spark-terasort-1.0-jar-with-dependencies.jar hdfs://${MASTER}:9000/data/terasort_in hdfs://${MASTER}:9000/data/terasort_out | tee -a $log
fi

echo "---------------------------------------------" | tee -a $log

rm -rf ${TERASORT_UTILS_DIR}/wdir/spark-terasort/output &>>/dev/null

mkdir ${TERASORT_UTILS_DIR}/wdir/spark-terasort/output

if [ $VALIDATE -eq 1 ]
then
 #   for slave in `echo $SLAVES |cut -d "=" -f2 | tr "," "\n" | cut -d "," -f1`
  #  do
   # echo -e '\nValidating Data on '$slave'' | tee -a $log

#    ${SPARK_HOME}/bin/spark-submit --conf 'spark.executor.extraJavaOptions=-Dos.arch=ppc64le' --master yarn --class com.github.ehiggs.spark.terasort.TeraValidate ${TERASORT_WORK_DIR}/spark-terasort/target/spark-terasort-1.0-jar-with-dependencies.jar hdfs://${MASTER}:9000/data/terasort_out hdfs://${slave}:9000/data/terasort_validate | tee -a ${TERASORT_UTILS_DIR}/wdir/spark-terasort/output/Validate_result_${slave}
   ${SPARK_HOME}/bin/spark-submit --conf 'spark.executor.extraJavaOptions=-Dos.arch=ppc64le' --master yarn --class com.github.ehiggs.spark.terasort.TeraValidate ${TERASORT_WORK_DIR}/spark-terasort/target/spark-terasort-1.0-jar-with-dependencies.jar hdfs://${MASTER}:9000/data/terasort_out  | tee -a ${TERASORT_UTILS_DIR}/wdir/spark-terasort/output/Validate_result

#done

fi

if [ ! -d ${TERASORT_WORK_DIR}/terasort_results ];
then
    mkdir ${TERASORT_WORK_DIR}/terasort_results
fi

cd ${TERASORT_UTILS_DIR}/wdir/spark-terasort/output

zip -r ${TERASORT_WORK_DIR}/terasort_results/terasort_output_$current_time.zip ./* &>>/dev/null


echo "Log file at $log" | tee -a $log 
echo "Results file at ${TERASORT_WORK_DIR}/terasort_results/terasort_output_$current_time.zip" | tee -a $log
echo -e "\n"
