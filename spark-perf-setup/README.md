# Spark-perf benchmark setup

### Pre-requisites:
1. Zip is installed on master machine 
2. Python is installed on master machine
2. Hadoop and spark setup is already completed using scripts at https://github.com/kmadhugit/hadoop-cluster-utils.git  and it is running on master & slave machines.


### Installations:

* To automate SPARK-PERF installation follows below steps,

  ```bash
  git clone https://github.com/kavanabhat/Spark-Benchmarks-Setup.git
  
  cd Spark-Benchmarks-Setup/spark-perf-setup
 
  ```
    
* Configuration

   1. To configure `spark-perf`, run `./install.sh`, it will clone the spark-perf repository under path `Spark-Benchmarks-Setup/spark-perf-setup/` and also will set the hadoop and spark related variables in config.py file for spak-perf.
   2. To run benchmark , run `./runbench.sh`. It will ask for options to select type of test to be run and scale factor if you want to change. Once all inputs received it will execute selected benchmarks.
   3. Output files for benchmarks will be stored in zip format at location `Spark-Benchmarks-Setup/spark-perf-results`
      
  ```

