# HiBench benchmark setup

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
    
###  Configuration

   1. To configure `HiBench`, run `./install.sh`, it will clone the HiBench repository under path `Spark-Benchmarks-Setup/hibench-setup/wdir` and also will set the hadoop and spark related variables in configuration files for HiBench. At the end, it will run build for HiBench.
   2. To run benchmark , run `./runbench.sh`. It will ask for options to select type of workloads to be run.Please select workload name in comma separated format for multiple inputs (e.g. sql,micro) or "all" if you want to run all workloads.
   3. Output files for benchmarks will be stored in zip format at location `Spark-Benchmarks-Setup/hibench-setup/wdir/hibench-results` and logs at `Spark-Benchmarks-Setup/hibench-setup/wdir/hibench-logs`
   4. If `./runbench.sh` is installing maven on redhat machine, please execute "source ~/.bashrc to export updated maven related environment variables in your current login session."
  ```


