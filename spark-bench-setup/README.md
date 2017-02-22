# Shell scripts to install spark-bench #

- Contents:

  1. Pre-requisites
  2. Overview
  3. How to Run the script
  4. KMeans
  5. Terasort
  6. SQL

---

### Pre-requisites:
1. Zip is installed on master machine 
2. Python is installed on master machine
3. Hadoop and spark setup is already completed using scripts at https://github.com/kmadhugit/hadoop-cluster-utils.git  and it is running on master & slave machines.
4. If you want to run spark workloads on hive, then hive needs to be installed and configured.


### Overview ###

The code is for easing the steps for installing spark bench. Currently this installs the spark bench from branch 2.0.1 of repo at https://github.com/MaheshIBM/spark-bench 

### How to run the script ###
Clone the repo and run ./install.sh at Spark-Benchmarks-Setup/spark-bench-setup. The code is tested to run on ubuntu 16.04.1 LTS.
After installation to run a workload use run_bench.sh for example to run Terasort the command is *./run_bench.sh Terasort*

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

**Output logs are located at /Spark-Benchmarks-Setup/spark-bench-setup/wdir/logs**

### KMeans ###
To execute the workload for KMeans, generate data followed by run. The configuration of the workload is at Spark-Benchmarks-Setup/spark-bench-setup/wdir/spark-bench/KMeans/conf/env.sh.
- You can edit the file *Spark-Benchmarks-Setup/spark-bench-setup/wdir/spark-bench/KMeans/conf/env.sh* to change the amount of data that gets generated. The data generated is stored in hdfs.
- The script to generate the data is *Spark-Benchmarks-Setup/spark-bench-setup/wdir/spark-bench/KMeans/bin/gen_data.sh*
- You run the workload with the script *Spark-Benchmarks-Setup/spark-bench-setup/wdir/spark-bench/KMeans/bin/run.sh*

### Terasort ###

To execute the workload for Terasort, generate data followed by run. The configuration of the workload is at Spark-Benchmarks-Setup/spark-bench-setup/wdir/spark-bench/Terasort/conf/env.sh.
- You can edit the file *Spark-Benchmarks-Setup/spark-bench-setup/wdir/spark-bench/Terasort/conf/env.sh* to change the amount of data that gets generated. The data generated is stored in hdfs.
- The script to generate the data is *Spark-Benchmarks-Setup/spark-bench-setup/wdir/spark-bench/Terasort/bin/gen_data.sh*
- You can run the workload with the script *Spark-Benchmarks-Setup/spark-bench-setup/wdir/spark-bench/Terasort/bin/run.sh*

### SQL ###
**The SQL benchmark by default uses SparkSQL. If you want to use Hive then pass argument hive to the run script. The gen data script for this does not support generating data of different sizes. It merely copies a local directory *(Spark-Benchmarks-Setup/spark-bench-setup/wdir/spark-bench/SQL/src/resources/sample_data_set)* to HDFS**

To execute the workload for SQL, generate data followed by run. The configuration of the workload is at Spark-Benchmarks-Setup/spark-bench-setup/wdir/spark-bench/SQL/conf/env.sh.
- You can edit the file *Spark-Benchmarks-Setup/spark-bench-setup/wdir/spark-bench/SQL/conf/env.sh* to change the amount of data that gets generated. The data generated is stored in hdfs.
- The script to generate the data is *Spark-Benchmarks-Setup/spark-bench-setup/wdir/spark-bench/SQL/bin/gen_data.sh*
- You can run the workload with the script *Spark-Benchmarks-Setup/spark-bench-setup/wdir/spark-bench/SQL/bin/run.sh*
- To run the workload using hive use *Spark-Benchmarks-Setup/spark-bench-setup/wdir/spark-bench/SQL/bin/run.sh hive*
