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

log=${HIBENCH_WORK_DIR}/hibench_logs/hibench_runbench_$current_time.log

rm -rf ${HIBENCH_WORK_DIR}/HiBench/report/* &>>/dev/null

cd ${HIBENCH_WORK_DIR}/HiBench

echo "Please enter types of workload you want to run graph/micro/ml/sql/websearch in format e.g. (graph,sql) or All"
read workload

workload=`echo ${workload} | tr '[:upper:]' '[:lower:]'`

if [ $workload = 'all' ]
then
	workload="graph,micro,ml,sql,websearch"
else
    echo $workload | grep -i 'all' &>>/dev/null
	if [ $? -eq 0 ]
	then
		echo 'Please enter option in correct format, '$workload' is not valid option' | tee -a $log
		exit 1
	else
		##check for validation of entered workload option 
		for i in `echo ${workload} | tr "," " "`
		do
			echo $i | grep -iE 'graph|micro|ml|sql|websearch' &>>/dev/null
			if [ $? -ne 0 ]
			then
				echo 'Please select correct workload to run '$i' is not valid option' | tee -a $log
				exit 1
			fi
		done
	fi
fi

echo 'selected workloads for run - '$workload'' | tee -a $log

for i in `echo ${workload} | tr "," " "`
do 
	if [ ${i} = "graph" ]
	then 
          
		echo -e '\nRunninng graph-nweight workload \n'  | tee -a $log
		${HIBENCH_WORK_DIR}/HiBench/bin/workloads/graph/nweight/prepare/prepare.sh | tee -a $log
		${HIBENCH_WORK_DIR}/HiBench/bin/workloads/graph/nweight/spark/run.sh | tee -a $log
		
	elif [ ${i} = "micro" ]
	then
		echo -e '\nRunninng micro-wordcount workload \n'  | tee -a $log
		${HIBENCH_WORK_DIR}/HiBench/bin/workloads/micro/wordcount/prepare/prepare.sh | tee -a $log
		${HIBENCH_WORK_DIR}/HiBench/bin/workloads/micro/wordcount/spark/run.sh | tee -a $log
		${HIBENCH_WORK_DIR}/HiBench/bin/workloads/micro/wordcount/hadoop/run.sh | tee -a $log
        
		echo -e '\nRunninng micro-terasort workload \n'  | tee -a $log
		${HIBENCH_WORK_DIR}/HiBench/bin/workloads/micro/terasort/prepare/prepare.sh | tee -a $log
		${HIBENCH_WORK_DIR}/HiBench/bin/workloads/micro/terasort/spark/run.sh | tee -a $log
		${HIBENCH_WORK_DIR}/HiBench/bin/workloads/micro/terasort/hadoop/run.sh | tee -a $log
        
		echo -e '\nRunninng micro-sort workload \n'  | tee -a $log
		${HIBENCH_WORK_DIR}/HiBench/bin/workloads/micro/sort/prepare/prepare.sh | tee -a $log
		${HIBENCH_WORK_DIR}/HiBench/bin/workloads/micro/sort/spark/run.sh | tee -a $log
		${HIBENCH_WORK_DIR}/HiBench/bin/workloads/micro/sort/hadoop/run.sh | tee -a $log
        
		echo -e '\nRunninng micro-sleep workload \n'  | tee -a $log
		${HIBENCH_WORK_DIR}/HiBench/bin/workloads/micro/sleep/prepare/prepare.sh | tee -a $log
		${HIBENCH_WORK_DIR}/HiBench/bin/workloads/micro/sleep/spark/run.sh | tee -a $log
		${HIBENCH_WORK_DIR}/HiBench/bin/workloads/micro/sleep/hadoop/run.sh | tee -a $log
        
		echo -e '\nRunninng micro-dfsioe workload \n'  | tee -a $log
		${HIBENCH_WORK_DIR}/HiBench/bin/workloads/micro/dfsioe/prepare/prepare.sh | tee -a $log
		${HIBENCH_WORK_DIR}/HiBench/bin/workloads/micro/dfsioe/hadoop/run.sh | tee -a $log

	elif [ ${i} = "ml" ]
	then
		echo -e '\nRunninng ml-bayes workload \n'  | tee -a $log
		${HIBENCH_WORK_DIR}/HiBench/bin/workloads/ml/bayes/prepare/prepare.sh | tee -a $log
		${HIBENCH_WORK_DIR}/HiBench/bin/workloads/ml/bayes/spark/run.sh | tee -a $log
		${HIBENCH_WORK_DIR}/HiBench/bin/workloads/ml/bayes/hadoop/run.sh | tee -a $log
        
		echo -e '\nRunninng ml-kmeans workload \n'  | tee -a $log
		${HIBENCH_WORK_DIR}/HiBench/bin/workloads/ml/kmeans/prepare/prepare.sh | tee -a $log
		${HIBENCH_WORK_DIR}/HiBench/bin/workloads/ml/kmeans/spark/run.sh | tee -a $log
		${HIBENCH_WORK_DIR}/HiBench/bin/workloads/ml/kmeans/hadoop/run.sh | tee -a $log

	elif [ ${i} = "websearch" ]
	then
		echo -e '\nRunninng websearch-pagerank workload \n'  | tee -a $log
		
		${HIBENCH_WORK_DIR}/HiBench/bin/workloads/websearch/pagerank/prepare/prepare.sh | tee -a $log
		${HIBENCH_WORK_DIR}/HiBench/bin/workloads/websearch/pagerank/hadoop/run.sh | tee -a $log
		${HIBENCH_WORK_DIR}/HiBench/bin/workloads/websearch/pagerank/spark/run.sh | tee -a $log
		
		echo -e '\nRunninng websearch-nutchindexing workload \n'  | tee -a $log
		${HIBENCH_WORK_DIR}/HiBench/bin/workloads/websearch/nutchindexing/prepare/prepare.sh | tee -a $log
		${HIBENCH_WORK_DIR}/HiBench/bin/workloads/websearch/nutchindexing/hadoop/run.sh | tee -a $log

	elif [ ${i} = "sql" ]
	then
	 
		echo -e '\nRunninng sql-aggregation workload \n'  | tee -a $log
		 ${HIBENCH_WORK_DIR}/HiBench/bin/workloads/sql/aggregation/prepare/prepare.sh | tee -a $log
		 ${HIBENCH_WORK_DIR}/HiBench/bin/workloads/sql/aggregation/spark/run.sh | tee -a $log
		 ${HIBENCH_WORK_DIR}/HiBench/bin/workloads/sql/aggregation/hadoop/run.sh | tee -a $log
		
         echo -e '\nRunninng sql-join workload \n'  | tee -a $log		
		 ${HIBENCH_WORK_DIR}/HiBench/bin/workloads/sql/join/prepare/prepare.sh | tee -a $log
		 ${HIBENCH_WORK_DIR}/HiBench/bin/workloads/sql/join/spark/run.sh | tee -a $log
		 ${HIBENCH_WORK_DIR}/HiBench/bin/workloads/sql/join/hadoop/run.sh | tee -a $log
		 
		 echo -e '\nRunninng sql-scan workload \n'  | tee -a $log		
		 ${HIBENCH_WORK_DIR}/HiBench/bin/workloads/sql/scan/prepare/prepare.sh | tee -a $log
		 ${HIBENCH_WORK_DIR}/HiBench/bin/workloads/sql/scan/spark/run.sh | tee -a $log
		 ${HIBENCH_WORK_DIR}/HiBench/bin/workloads/sql/scan/hadoop/run.sh | tee -a $log
	fi 
done
 
if [ ! -d ${HIBENCH_WORK_DIR}/hibench_results ]
then
    mkdir ${HIBENCH_WORK_DIR}/hibench_results  
fi

echo "---------------------------------------------" | tee -a $log

cd ${HIBENCH_WORK_DIR}/HiBench/report
cp ${HIBENCH_WORK_DIR}/HiBench/report/hibench.report ${HIBENCH_WORK_DIR}/hibench_results/hibench.report_$current_time
zip -r ${HIBENCH_WORK_DIR}/hibench_results/hibench_output_$current_time.zip ./* &>>/dev/null

echo 'You can check results at location '${HIBENCH_WORK_DIR}'/hibench_results and logs at location '${HIBENCH_WORK_DIR}'/hibench_logs' | tee -a $log
