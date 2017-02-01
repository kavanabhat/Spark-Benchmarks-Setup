# Spark-perf benchmark setup
### Set passwordless login

To create user
```
sudo adduser testuser
sudo adduser testuser sudo
```

For local host

```
ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa 
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
chmod 0600 ~/.ssh/authorized_keys
 ```
For other hosts

```
ssh-copy-id -i ~/.ssh/id_rsa.pub user@host
ssh user@host
```

### Pre-requisities:
1. JAVA Setup should be completed and JAVA_HOME should be set in the ~/.bashrc file (environment variable).
2. Make sure the nodes are set for password-less SSH both ways(master->slaves).
3. Since we use the environment variables a lot in our scripts, make sure to comment out the portion following this statement in your ~/.bashrc , 
`If not running interactively, don't do anything`. Update .bashrc

 Delete/comment the following check.
  ```
   # If not running interactively, don't do anything
   case $- in
       *i*) ;;
         *) return;;
   esac
  ```
4. Same username/useraccount should be need on `master` and `slaves` nodes for multinode installation.

### Installations:

* To automate hadoop installation follows the steps,

  ```bash
  git clone https://github.com/nkalband/Spark-perf-automation.git
  
  cd spark-perf-automation
 
  ```
    
* Configuration

   1. Hadoop setup is already completed using scripts at https://github.com/kmadhugit/hadoop-cluster-utils.git  and it is running on master & slave machines.
   2.To configure `spark-perf`, run `./autogen_sparkperf.sh` which will create `config.sh` with appropriate field values.
   3. User can enter SLAVEIPs (if more than one, use comma seperated) interactively while running `./autogen.sh` file.
   4. Default `Spark-2.0.1` and `Hadoop-2.7.1` version available for installation. 
   5. Before executing `./setup_sparkperf.sh` file, user can verify or edit `config.sh` 
   6. Once setup script completed,source `~/.bashrc` file to export updated spark environment variables for current login session. 
   
  ```
 
* Spark web Address
  
  Spark            : http://localhost:8080 (Default)
  ```
 
* Useful scripts
 
  ```
   > stop-all.sh #stop spark
   > start-all.sh #start spark
   > CP <localpath to file> <remotepath to dir> #Copy file from name nodes to all slaves
   > AN <command> #execute a given command in all nodes including master
   > DN <command> #execute a given command in all nodes excluding master
   ```
