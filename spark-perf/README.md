# Spark-perf benchmark setup

### Pre-requisites:
1. Zip is installed on master machine 
2. Hadoop and spark setup is already completed using scripts at https://github.com/kmadhugit/hadoop-cluster-utils.git  and it is running on master & slave machines.


### Installations:

* To automate SPARK-PERF installation follows below steps,

  ```bash
  git clone https://github.com/kavanabhat/Spark-Benchmarks-Setup.git
  
  cd Spark-Benchmarks-Setup/spark-perf
 
  ```
    
* Configuration

   1. To configure `spark-perf`, run `./autogen_sparkperf.sh` which will create `config` with appropriate field values considering existing hadoop and spark setup.It will ask for options to select type of test to be run and scale factor.
   2. Before executing `./setup_sparkperf.sh` file, user can verify or edit `config` 
   3. Run `./setup_sparkperf.sh` to execute bechmark run for selected tests
      
  ```

