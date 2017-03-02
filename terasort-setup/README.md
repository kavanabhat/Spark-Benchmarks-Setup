# HiBench benchmark setup

### Pre-requisites:
1. Zip is installed on master machine 
2. Maven is installed on master machine
2. Hadoop and spark setup is already completed using scripts at https://github.com/kmadhugit/hadoop-cluster-utils.git  and it is running on master & slave machines.


### Installations:

* To automate Terasort installation follows below steps,

  ```bash
  git clone https://github.com/kavanabhat/Spark-Benchmarks-Setup.git
  
  cd Spark-Benchmarks-Setup/terasort-setup
 
  ```
    
###  Configuration

   1. To configure `Terasort`, run `./install.sh`, it will clone the Terasort repository under path `Spark-Benchmarks-Setup/terasort-setup/wdir` and also will set the hadoop and spark related variables in configuration files for HiBench. At the end, it will run build command for Terasort.
   2. To run terasort , run `./runbench.sh`. it will first generate the data to Master HDFS file (data/terasort_in)and then Sort the data into HDFS (data/terasort_out),after that we validate the data in YARN mode between avaiable slaves and data is store in Slaves hdfs (data/terasort_validate)
   3. Output files for sorting validate data will be stored in zip format at location `Spark-Benchmarks-Setup/terasort-setup/wdir/terasort_results` and logs at `Spark-Benchmarks-Setup/terasort-setup/wdir/terasort_logs`
  ```


