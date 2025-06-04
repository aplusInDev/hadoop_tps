#!/bin/bash

# Download and extract Spark
sudo wget https://archive.apache.org/dist/spark/spark-2.4.8/spark-2.4.8-bin-hadoop2.7.tgz
sudo tar -xzf spark-2.4.8-bin-hadoop2.7.tgz
sudo mv spark-2.4.8-bin-hadoop2.7 /opt/spark
sudo chown -R user:user /opt/spark

# Update bashrc and source it
cat hadoop_tps/tp5/cfg2_4/bashrc >> ~/.bashrc
source ~/.bashrc

# Configure spark-env.sh
sudo cp $SPARK_HOME/conf/spark-env.sh.template $SPARK_HOME/conf/spark-env.sh
cat ~/hadoop_tps/tp5/cfg2_4/spark-env.sh | sudo tee -a /opt/spark/conf/spark-env.sh > /dev/null

# Handle workers/slaves file (check which template exists)
if [ -f "$SPARK_HOME/conf/workers.template" ]; then
    sudo cp $SPARK_HOME/conf/workers.template $SPARK_HOME/conf/workers
elif [ -f "$SPARK_HOME/conf/slaves.template" ]; then
    sudo cp $SPARK_HOME/conf/slaves.template $SPARK_HOME/conf/slaves
    # For older Spark versions, create workers file from slaves
    sudo cp $SPARK_HOME/conf/slaves $SPARK_HOME/conf/workers
fi

if [ "$1" = "master" ]; then
    # Configure workers file
    if [ -f "hadoop_tps/tp5/cfg2_4/workers" ]; then
        sudo cp hadoop_tps/tp5/cfg2_4/workers $SPARK_HOME/conf/workers
        # Also copy to slaves file for compatibility
        sudo cp hadoop_tps/tp5/cfg2_4/workers $SPARK_HOME/conf/slaves
    fi

    # Configure spark-defaults.conf
    sudo cp $SPARK_HOME/conf/spark-defaults.conf.template $SPARK_HOME/conf/spark-defaults.conf
    cat hadoop_tps/tp5/cfg2_4/spark-defaults.conf | sudo tee -a /opt/spark/conf/spark-defaults.conf > /dev/null

    # Create HDFS directories
    hdfs dfs -mkdir -p /spark-logs
    hdfs dfs -mkdir -p /spark-history
    hdfs dfs -chmod -R 777 /spark-logs
    hdfs dfs -chmod -R 777 /spark-history

    # Copy Spark to worker nodes (fixed approach)
    for worker in slave1 slave2; do
        echo "Copying Spark to $worker..."
        
        # Copy Spark directory to worker's tmp first, then move with sudo
        scp -r /opt/spark $worker:/tmp/
        ssh $worker "sudo mv /tmp/spark /opt/ && sudo chown -R user:user /opt/spark"
        
        # Copy bashrc
        scp ~/.bashrc $worker:/tmp/.bashrc_new
        ssh $worker "mv /tmp/.bashrc_new ~/.bashrc && source ~/.bashrc"
        
        echo "Spark copied to $worker successfully"
    done

    # Wait a moment for file operations to complete
    sleep 2

    # Create and upload Spark JARs archive
    echo "Creating Spark JARs archive..."
    cd $SPARK_HOME/jars
    
    # Remove existing archive if it exists
    rm -f spark-jars.zip
    zip -r spark-jars.zip *
    
    # Remove existing archive from HDFS if it exists
    hdfs dfs -rm -f /spark-jars.zip
    hdfs dfs -put spark-jars.zip /
    
    cd - # Return to previous directory

    # Start Spark services
    echo "Starting Spark services..."
    $SPARK_HOME/sbin/start-master.sh
    
    # Wait for master to start
    sleep 5
    
    $SPARK_HOME/sbin/start-slaves.sh
    $SPARK_HOME/sbin/start-history-server.sh

    # Wait for services to start
    sleep 3

    echo "Spark installation and startup complete!"
    echo "Checking running processes:"
    jps
    
    echo ""
    echo "Access Spark Web UIs at:"
    echo "- Master UI: http://$(hostname):8080"
    echo "- History Server: http://$(hostname):18080"
    
else
    echo "Script completed for worker node. Services will be started from master."
fi
