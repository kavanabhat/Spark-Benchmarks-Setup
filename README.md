#Benchmark Automation 
This repository contains shell scripts to setup and execute below spark benchmarks
1. Spark-perf
2. spark-bench
3. Hibench
4. Terasort

Below are steps followed for specific benchmark setup and run 

# Spark-perf setup

### Pre-requisites:
1. Zip is installed on master machine 
2. Python is installed on master machine
3. Hadoop and spark setup is already completed using scripts at https://github.com/kmadhugit/hadoop-cluster-utils.git  and it is running on master & slave machines.
4. WORKDIR is set as environment variable.

### Installations:
* To automate SPARK-PERF installation follows below steps,

  ```bash
  git clone https://github.com/kavanabhat/Spark-Benchmarks-Setup.git
  
  cd Spark-Benchmarks-Setup/spark-perf-setup
  ```
    
### How to run the script ###
   1. To configure `spark-perf`, run `./install.sh`, it will clone the spark-perf repository under path `Spark-Benchmarks-Setup/spark-perf-setup/` and also will set the hadoop and spark related variables in config.py file for spak-perf.
   2. To run benchmark , run `./runbench.sh`. It will ask for options to select type of test to be run and scale factor if you want to change. Once all inputs received it will execute selected benchmarks.
   3. Output files for benchmarks will be stored in zip format at location `Spark-Benchmarks-Setup/spark-perf-setup/wdir/spark-perf-results` and logs at `Spark-Benchmarks-Setup/spark-perf-setup/wdir/spark-perf-logs`

# Spark-bench setup

### Pre-requisites:
1. Zip is installed on master machine 
2. Python is installed on master machine
3. Hadoop and spark setup is already completed using scripts at https://github.com/kmadhugit/hadoop-cluster-utils.git  and it is running on master & slave machines.
4. If you want to run spark workloads on hive, then hive needs to be installed and configured.
5. The script install git-extras which needs the epel repo incase you are using redhat. Following are the steps to add the epel repo.
 - rpm --import http://download.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-7
 - yum-config-manager --add-repo https://dl.fedoraproject.org/pub/epel/7/ppc64le/

### Overview ###
The code is for easing the steps for installing spark bench. Currently this installs the spark bench from branch 2.0.1 of repo at https://github.com/MaheshIBM/spark-bench 

### How to run the script ###
Clone the repo and run ./install.sh at Spark-Benchmarks-Setup/spark-bench-setup. The code is tested to run on ubuntu 16.04.1 LTS and Red Hat Enterprise Linux Server release 7.2 (Maipo).
After installation to run a workload use run_bench.sh for example to run Terasort the command is *./run_bench.sh -cr Terasort*
Use -c flag to create data, -r to only run and -cr if you want to create and run.

# HiBench setup

### Pre-requisites:
1. Zip is installed on master machine 
2. Maven and Python is installed on master machine
3. Hadoop and spark setup is already completed using scripts at https://github.com/kmadhugit/hadoop-cluster-utils.git  and it is running on master & slave machines.
4. Also Hive and mysql setup is completed using script mentioned in above point 3. 
5. Set shell environment variable `WORKDIR` to path where you want to clone/install git repository of hibench-setup (e.g. export WORKDIR=/home/testuser)

### Installations:
* To automate HiBench installation follows below steps,

  ```bash
  git clone https://github.com/kavanabhat/Spark-Benchmarks-Setup.git
  
  cd Spark-Benchmarks-Setup/hibench-setup
  ```
    
### How to run the script ###

   1. To configure `HiBench`, run `./install.sh`, it will clone the HiBench repository under path `Spark-Benchmarks-Setup/hibench-setup/wdir` and also will set the hadoop and spark related variables in configuration files for HiBench. At the end, it will run build for HiBench.
   2. If `./install.sh` is installing maven on redhat machine, please execute "source ~/.bashrc to export updated maven related environment variables in your current login session.
   3. To run benchmark , run `./runbench.sh`. It will ask for options to select type of workloads to be run.Please select workload name in comma separated format for multiple inputs (e.g. sql,micro) or "all" if you want to run all workloads.
   4. Output files for benchmarks will be stored in zip format at location `Spark-Benchmarks-Setup/hibench-setup/wdir/hibench-results` and logs at `Spark-Benchmarks-Setup/hibench-setup/wdir/hibench-logs`

# Terasort setup

### Pre-requisites:
1. Zip is installed on master machine 
2. Maven is installed on master machine
2. Hadoop and spark setup is already completed using scripts at https://github.com/kmadhugit/hadoop-cluster-utils.git  and it is running on master & slave machines.


### How to install:

  ```bash
  git clone https://github.com/kavanabhat/Spark-Benchmarks-Setup.git
  
  cd Spark-Benchmarks-Setup/terasort-setup
 
  ```
 ### How to run the script ###  
   1. To clone and build the `Terasort` code, run `./install.sh`, it will clone the Terasort repository under path `Spark-Benchmarks-Setup/terasort-setup/wdir` and also will set the hadoop and spark related variables in configuration files for Terasort. At the end, it will run build command for Terasort.
   2. To run terasort , run `./runbench.sh`. Depending on the options selected, it will first generate the data to HDFS file (data/terasort_in)and then sort the data into HDFS (data/terasort_out), after that the data is validated and the validation output is stored in hdfs at (data/terasort_validate)
   3. Output files for sorting/validation/data generation will be stored in zip format at location `Spark-Benchmarks-Setup/terasort-setup/wdir/terasort_results`