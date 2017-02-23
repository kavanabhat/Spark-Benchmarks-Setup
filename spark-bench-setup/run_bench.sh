#/bin/bash

#usage
# get_secondlast_log /home/log
function get_secondlast_log(){
    echo $(ls -lt $1 | head -3 | tail -1 | awk -F ' ' '{print $9 }')
}

array=("  ConnectedComponent
        DecisionTree
        KMeans
        LabelPropagation
        LinearRegression
        LogisticRegression
        MatrixFactorization
        PageRank
        PCA
        PregelOperation
        ShortestPaths
        SQL
        StronglyConnectedComponent
        SVDPlusPlus
        SVM
        Terasort
        TriangleCount")

display_usage() { 
	echo "Usage: ./runbench.sh -cr workload_name" 
        echo "-c : create data"
        echo "-r : run workload"
        echo "For example: ./runbench.sh -cr SQL => this will create data and run the SQL workload"
        echo "For example: ./runbench.sh -c SQL => this will create data for the SQL workload"
        echo -e "For example: ./runbench.sh -r SQL => this will run the SQL workload\n"
	echo -e "  Following can be the values for workload_name:\n"
	for a in $array; do echo "  $a"; done
        echo "To run SQL workload on hive use SQL hive"
}


if [  $# -le 1  ] 
then 
    display_usage
    exit 1
fi 

CREATE_DATA=0
RUN=0

while getopts "cr" opt; do
  case $opt in
    c)
      CREATE_DATA=1
      ;;
    r)
      RUN=1
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      display_usage
      exit 1
      ;;
  esac
done
#last parameter is always the workload name
WORKLOAD_NAME="${@: -1}"
EXTRA_OPTS=""

#Handle the case to run sql on hive.
if [ $WORKLOAD_NAME = "hive" ]
then
  EXTRA_OPTS=$WORKLOAD_NAME
  WORKLOAD_NAME="${@: -2:1}" #workload name is now second last parameter
fi

if [[ ! " ${array[@]} " =~ "$WORKLOAD_NAME" ]] 
 then echo "**Invalid workload name: $WORKLOAD_NAME**"
 display_usage
 exit 1
fi

BASEDIR=$(dirname "$0")
export BENCH_NUM="$BASEDIR/wdir/logs"

if [ $CREATE_DATA -eq 1 ] 
then
    echo "**Generating Data**"
    $BASEDIR/wdir/spark-bench/$WORKLOAD_NAME/bin/gen_data.sh $EXTRA_OPTS
    #All datacreation scripts dont create logs, so not simple to print log file name here.
else
    echo "**Skipping data generation**"
fi

if [ $RUN -eq 1 ]
then
    $BASEDIR/wdir/spark-bench/$WORKLOAD_NAME/bin/run.sh $EXTRA_OPTS
    echo "Run complete: log location => $(realpath $BENCH_NUM)/$(get_secondlast_log $BENCH_NUM)"
fi
