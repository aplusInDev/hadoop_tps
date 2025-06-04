# Start Spark master
$SPARK_HOME/sbin/start-master.sh

# Start all workers
$SPARK_HOME/sbin/start-slaves.sh

# Or start workers individually on each node
# On slave1 and slave2:
# $SPARK_HOME/sbin/start-slave.sh spark://master:7077

# Start the Spark History Server
$SPARK_HOME/sbin/start-history-server.sh