sudo wget https://archive.apache.org/dist/spark/spark-2.4.8/spark-2.4.8-bin-hadoop2.7.tgz
sudo tar -xzf spark-2.4.8-bin-hadoop2.7.tgz
sudo mv spark-2.4.8-bin-hadoop2.7 /opt/spark
sudo chown -R user:user /opt/spark

cat hadoop_tps/tp5/cfg/bashrc >> ~/.bashrc
source ~/.bashrc

sudo cp $SPARK_HOME/conf/spark-env.sh.template $SPARK_HOME/conf/spark-env.sh
sudo cat hadoop_tps/tp5/cfg/spark-env.sh >> $SPARK_HOME/conf/spark-env.sh

sudo cp $SPARK_HOME/conf/workers.template $SPARK_HOME/conf/workers

if [ "$1" = "master" ]; then
    sudo cp hadoop_tps/tp5/cfg/workers $SPARK_HOME/conf/workers

    sudo cp $SPARK_HOME/conf/spark-defaults.conf.template $SPARK_HOME/conf/spark-defaults.conf
    sudo cat hadoop_tps/tp5/cfg/spark-defaults.conf >> $SPARK_HOME/conf/spark-defaults.conf

    hdfs dfs -mkdir /spark-logs
    hdfs dfs -mkdir /spark-history
    hdfs dfs -chmod -R 777 /spark-logs
    hdfs dfs -chmod -R 777 /spark-history

    for worker in slave1 slave2; do
        scp -r /opt/spark $worker:/opt/
        scp ~/.bashrc $worker:~/.bashrc
        ssh $worker "source ~/.bashrc"
    done

    # Create and upload Spark JARs archive
    cd $SPARK_HOME/jars
    zip -r spark-jars.zip *
    hdfs dfs -put spark-jars.zip /

    $SPARK_HOME/sbin/start-master.sh
    $SPARK_HOME/sbin/start-slaves.sh
    $SPARK_HOME/sbin/start-history-server.sh

    jps
fi
