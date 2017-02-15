# Shell scripts to install spark-bench #

- Contents:

  1. Overview
  2. How to Run the script
  3. KMeans
  4. Terasort
  5. SQL

---
### Overview ###

The code is for easing the steps for installing spark bench. Currently this installs the spark bench from branch 2.0.1 of repo at https://github.com/MaheshIBM/spark-bench 

### How to run the script ###
Clone the file and run ./install.sh. The code is tested to run on ubuntu 16.

### Overall configuration ###
The overall configuration about the cluster is kept at spark-bench/conf/env.sh.
This includes such things as, go through the file to see a complete list of all configurable spark and other parameters.
- Master
- List of slaves
- Version of spark used
- URL for the master - this can be yarn, spark or spark standalone (local[x])

### Below is a description of each of workloads that has been tested. ###
In addition to the overall configuration, every work load has its own configuration.
The configuration file is stored at spark-bench/[Workload]/conf/env.sh. For example, for the Terasort workload, the configuration file is located at *spark-bench/Terasort/conf/env.sh*. This will contain configuration that decides the amount of data to be generated and other config specific to the workload.

### KMeans ###
To execute the workload for KMeans, generate data followed by run. The configuration of the workload is at Spark-Benchmarks-Setup/spark-bench-auto/wdir/spark-bench/KMeans/conf/env.sh.
You can edit the file to change the amount of data that gets generated. The data generated is stored in hdfs.
The script to generate the data is Spark-Benchmarks-Setup/spark-bench-auto/wdir/spark-bench/KMeans/bin/gen_data.sh

You run the workload with the script Spark-Benchmarks-Setup/spark-bench-auto/wdir/spark-bench/KMeans/bin/run.sh

### Terasort ###

To execute the workload for Terasort, generate data followed by run. The configuration of the workload is at Spark-Benchmarks-Setup/spark-bench-auto/wdir/spark-bench/Terasort/conf/env.sh.
You can edit the file to change the amount of data that gets generated. The data generated is stored in hdfs.
The script to generate the data is Spark-Benchmarks-Setup/spark-bench-auto/wdir/spark-bench/Terasort/bin/gen_data.sh

You run the workload with the script Spark-Benchmarks-Setup/spark-bench-auto/wdir/spark-bench/Terasort/bin/run.sh

### SQL ###
The SQL benchmark by default uses SparkSQL. If you want to use Hive then pass argument hive to the run script.


To execute the workload for SQL, generate data followed by run. The configuration of the workload is at Spark-Benchmarks-Setup/spark-bench-auto/wdir/spark-bench/SQL/conf/env.sh.
You can edit the file to change the amount of data that gets generated. The data generated is stored in hdfs.
The script to generate the data is Spark-Benchmarks-Setup/spark-bench-auto/wdir/spark-bench/SQL/bin/gen_data.sh

You run the workload with the script Spark-Benchmarks-Setup/spark-bench-auto/wdir/spark-bench/SQL/bin/run.sh
To run the workload using hive use Spark-Benchmarks-Setup/spark-bench-auto/wdir/spark-bench/SQL/bin/run.sh hive
