#/bin/bash

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
	echo "Usage: ./runbench.sh benchmark_name" 
	echo -e "  Following can be the values for benchmark_name:\n"
	for a in $array; do echo "  $a"; done
}


if [  $# -le 0 ] 
then 
    display_usage
    exit 1
fi 

BENCHMARK_NAME=$1

if [[ ! " ${array[@]} " =~ "$BENCHMARK_NAME" ]] 
 then echo "**Invalid option: $BENCHMARK_NAME**"
 display_usage
 exit 1
fi

BASEDIR=$(dirname "$0")
export BENCH_NUM="$BASEDIR/wdir/logs"

$BASEDIR/wdir/spark-bench/$BENCHMARK_NAME/bin/gen_data.sh && $BASEDIR/wdir/spark-bench/$BENCHMARK_NAME/bin/run.sh 
