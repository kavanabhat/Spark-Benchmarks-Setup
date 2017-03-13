# HiBench benchmark setup

### Pre-requisites:
1. Zip is installed on master machine 
2. Maven is installed on master machine
2. Hadoop and spark setup is already completed using scripts at https://github.com/kmadhugit/hadoop-cluster-utils.git  and it is running on master & slave machines.


### How to install:


  ```bash
  git clone https://github.com/kavanabhat/Spark-Benchmarks-Setup.git
  
  cd Spark-Benchmarks-Setup/terasort-setup
 
  ```
    
   1. To clone and build the `Terasort` code, run `./install.sh`, it will clone the Terasort repository under path `Spark-Benchmarks-Setup/terasort-setup/wdir` and also will set the hadoop and spark related variables in configuration files for HiBench. At the end, it will run build command for Terasort.
   2. To run terasort , run `./runbench.sh`. Depending on the options selected, it will first generate the data to HDFS file (data/terasort_in)and then sort the data into HDFS (data/terasort_out), after that the data is validated and the validation output is stored in hdfs at (data/terasort_validate)
   3. Output files for sorting/validation/data generation will be stored in zip format at location `Spark-Benchmarks-Setup/terasort-setup/wdir/terasort_results` and logs at `Spark-Benchmarks-Setup/terasort-setup/wdir/terasort_logs`
