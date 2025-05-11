start-dfs.sh
start-yarn.sh

#!/bin/bash


# Give services time to start
sleep 15

# Check if NodeManager is running, start if not
if ! jps | grep -q 'NodeManager'; then
    echo "NodeManager not found. Starting NodeManager..."
    $HADOOP_HOME/sbin/yarn-daemon.sh start nodemanager
fi

echo "hdfs and yarn services started."