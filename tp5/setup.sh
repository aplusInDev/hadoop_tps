wget https://archive.apache.org/dist/spark/spark-3.5.5/spark-3.5.5-bin-hadoop3.tgz
tar -xzf spark-3.5.5-bin-hadoop3.tgz
sudo mv spark-3.5.5-bin-hadoop3 /opt/spark
cat hadoop_tps/tp5/cfg/bashrc >> ~/.bashrc
source ~/.bashrc
cp $SPARK_HOME/conf/spark-env.sh.template $SPARK_HOME/conf/spark-env.sh
cat hadoop_tps/tp5/cfg/spark-env.sh >> $SPARK_HOME/conf/spark-env.sh
cp $SPARK_HOME/conf/workers.template $SPARK_HOME/conf/workers

if [ "$1" = "master" ]; then
    cat hadoop_tps/tp5/cfg/workers >> $SPARK_HOME/conf/workers
    cp $SPARK_HOME/conf/spark-defaults.conf.template $SPARK_HOME/conf/spark-defaults.conf
    cat hadoop_tps/tp5/cfg/spark-defaults.conf >> $SPARK_HOME/conf/spark-defaults.conf

    hdfs dfs -mkdir /spark-logs
    hdfs dfs -mkdir /spark-history
    hdfs dfs -chmod -R 777 /spark-logs
    hdfs dfs -chmod -R 777 /spark-history

    for worker in slave1 slave2; do
        scp -r /opt/spark $worker:/opt/
        scp ~/.bashrc $worker:~/.bashrc
        ssh $worker "source ~/.bashrc"
    done

    $SPARK_HOME/sbin/start-master.sh
    $SPARK_HOME/sbin/start-workers.sh
    $SPARK_HOME/sbin/start-history-server.sh

    jps
fi