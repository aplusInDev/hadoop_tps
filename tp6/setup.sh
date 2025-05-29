if [ $# -eq 0 ] || ([ "$1" != "master" ] && [ "$1" != "slave1" ] && [ "$1" != "slave2" ]); then
    echo "Usage: $0 [master|slave1|slave2]"
    exit 1
fi

node_name=$1
echo "Setting up $node_name node..."

# Navigate to installation directory
cd /opt

# Download ZooKeeper 3.8.4
sudo wget https://archive.apache.org/dist/zookeeper/zookeeper-3.8.4/apache-zookeeper-3.8.4-bin.tar.gz

# Download Kafka 3.9.0
sudo wget https://archive.apache.org/dist/kafka/3.9.0/kafka_2.13-3.9.0.tgz

# Extract ZooKeeper
sudo tar -xzf apache-zookeeper-3.8.4-bin.tar.gz
sudo mv apache-zookeeper-3.8.4-bin zookeeper

# Extract Kafka
sudo tar -xzf kafka_2.13-3.9.0.tgz
sudo mv kafka_2.13-3.9.0 kafka

# Set ownership
sudo chown -R $USER:$USER /opt/zookeeper
sudo chown -R $USER:$USER /opt/kafka

# Clean up
sudo rm apache-zookeeper-3.8.4-bin.tar.gz kafka_2.13-3.9.0.tgz

cat hadoop_tps/tp6/cfg/bashrc >> ~/.bashrc
# Source the updated .bashrc
source ~/.bashrc

sudo mkdir -p /var/lib/zookeeper
sudo chown -R $USER:$USER /var/lib/zookeeper

cat hadoop_tps/tp6/cfg/zoo.cfg > /opt/zookeeper/conf/zoo.cfg


if [ "$node_name" == "master" ]; then
    echo "1" > /var/lib/zookeeper/myid
elif [ "$node_name" == "slave1" ]; then
    echo "2" > /var/lib/zookeeper/myid
elif [ "$node_name" == "slave2" ]; then
    echo "3" > /var/lib/zookeeper/myid
fi

cat hadoop_tps/tp6/cfg/zookeeper-env.sh >> /opt/zookeeper/conf/zookeeper-env.sh

# Create log directory
sudo mkdir -p /var/log/zookeeper
sudo chown -R $USER:$USER /var/log/zookeeper

sudo mkdir -p /var/lib/kafka-logs
sudo chown -R $USER:$USER /var/lib/kafka-logs


cp /opt/kafka/config/server.properties /opt/kafka/config/server.properties.backup
cat hadoop_tps/tp6/cfg/server.properties >> /opt/kafka/config/server.properties

if [ "$node_name" == "slave1" ]; then
    sed -i 's/broker.id=1/broker.id=2/' /opt/kafka/config/server.properties
    sed -i 's/listeners=PLAINTEXT:\/\/master:9092/listeners=PLAINTEXT:\/\/slave1:9092/' /opt/kafka/config/server.properties
    sed -i 's/advertised.listeners=PLAINTEXT:\/\/master:9092/advertised.listeners=PLAINTEXT:\/\/slave1:9092/' /opt/kafka/config/server.properties
elif [ "$node_name" == "slave2" ]; then
    sed -i 's/broker.id=1/broker.id=3/' /opt/kafka/config/server.properties
    sed -i 's/listeners=PLAINTEXT:\/\/master:9092/listeners=PLAINTEXT:\/\/slave2:9092/' /opt/kafka/config/server.properties
    sed -i 's/advertised.listeners=PLAINTEXT:\/\/master:9092/advertised.listeners=PLAINTEXT:\/\/slave2:9092/' /opt/kafka/config/server.properties
fi

cat hadoop_tps/tp6/cfg/kafka-server-start-env.sh >> /opt/kafka/bin/kafka-server-start-env.sh

# Create log directory
sudo mkdir -p /var/log/kafka
sudo chown -R $USER:$USER /var/log/kafka

echo "Setup for $node_name node completed."
