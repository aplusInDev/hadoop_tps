#!/bin/bash

# Kafka-ZooKeeper Setup Script
# Usage: ./setup.sh [master|slave1|slave2]

set -e  # Exit on any error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Validate arguments
if [ $# -eq 0 ] || ([ "$1" != "master" ] && [ "$1" != "slave1" ] && [ "$1" != "slave2" ]); then
    print_error "Usage: $0 [master|slave1|slave2]"
    exit 1
fi

node_name=$1
print_status "Setting up $node_name node..."

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    print_error "Please do not run this script as root. Run as regular user with sudo privileges."
    exit 1
fi

# Check if Java is installed
if ! command -v java &> /dev/null; then
    print_error "Java is not installed. Please install Java 8 or 11 first."
    exit 1
fi

print_status "Java version: $(java -version 2>&1 | head -n1)"

# Check if required config files exist
config_files=(
    "/home/user/hadoop_tps/tp6/cfg/bashrc"
    "/home/user/hadoop_tps/tp6/cfg/zoo.cfg" 
    "/home/user/hadoop_tps/tp6/cfg/zookeeper-env.sh"
    "/home/user/hadoop_tps/tp6/cfg/server.properties"
    "/home/user/hadoop_tps/tp6/cfg/kafka-server-start-env.sh"
)

for config_file in "${config_files[@]}"; do
    if [ ! -f "$config_file" ]; then
        print_error "Configuration file $config_file not found!"
        exit 1
    fi
done

print_status "All configuration files found. Proceeding with installation..."

# Navigate to installation directory
cd /opt

# Check if already installed
if [ -d "/opt/zookeeper" ] || [ -d "/opt/kafka" ]; then
    print_warning "ZooKeeper or Kafka already exists in /opt/. Skipping download."
else
    print_status "Downloading ZooKeeper 3.8.4..."
    sudo wget -q --show-progress https://archive.apache.org/dist/zookeeper/zookeeper-3.8.4/apache-zookeeper-3.8.4-bin.tar.gz

    print_status "Downloading Kafka 3.9.0..."
    sudo wget -q --show-progress https://archive.apache.org/dist/kafka/3.9.0/kafka_2.13-3.9.0.tgz

    print_status "Extracting ZooKeeper..."
    sudo tar -xzf apache-zookeeper-3.8.4-bin.tar.gz
    sudo mv apache-zookeeper-3.8.4-bin zookeeper

    print_status "Extracting Kafka..."
    sudo tar -xzf kafka_2.13-3.9.0.tgz
    sudo mv kafka_2.13-3.9.0 kafka

    # Set ownership
    sudo chown -R user:user /opt/zookeeper
    sudo chown -R user:user /opt/kafka

    # Clean up
    sudo rm apache-zookeeper-3.8.4-bin.tar.gz kafka_2.13-3.9.0.tgz
    print_status "Download and extraction completed."
fi

# Update .bashrc
print_status "Updating environment variables..."
if ! grep -q "ZOOKEEPER_HOME" ~/.bashrc; then
    cat /home/user/hadoop_tps/tp6/cfg/bashrc >> ~/.bashrc
    print_status "Environment variables added to ~/.bashrc"
else
    print_warning "Environment variables already exist in ~/.bashrc"
fi

# Source the updated .bashrc
source ~/.bashrc

# Create ZooKeeper directories
print_status "Creating ZooKeeper directories..."
sudo mkdir -p /var/lib/zookeeper
sudo mkdir -p /var/log/zookeeper
sudo chown -R user:user /var/lib/zookeeper
sudo chown -R user:user /var/log/zookeeper

# Configure ZooKeeper
print_status "Configuring ZooKeeper..."
cp /home/user/hadoop_tps/tp6/cfg/zoo.cfg /opt/zookeeper/conf/zoo.cfg

# Set myid based on node
print_status "Setting ZooKeeper myid for $node_name..."
if [ "$node_name" == "master" ]; then
    echo "1" > /var/lib/zookeeper/myid
elif [ "$node_name" == "slave1" ]; then
    echo "2" > /var/lib/zookeeper/myid
elif [ "$node_name" == "slave2" ]; then
    echo "3" > /var/lib/zookeeper/myid
fi

# Configure ZooKeeper environment
print_status "Configuring ZooKeeper environment..."
# Create zookeeper-env.sh if it doesn't exist
if [ ! -f "/opt/zookeeper/conf/zookeeper-env.sh" ]; then
    touch /opt/zookeeper/conf/zookeeper-env.sh
fi
# Append only if not already present
if ! grep -q "JAVA_HOME" /opt/zookeeper/conf/zookeeper-env.sh; then
    cat /home/user/hadoop_tps/tp6/cfg/zookeeper-env.sh >> /opt/zookeeper/conf/zookeeper-env.sh
fi

# Create Kafka directories
print_status "Creating Kafka directories..."
sudo mkdir -p /var/lib/kafka-logs
sudo mkdir -p /var/log/kafka
sudo chown -R user:user /var/lib/kafka-logs
sudo chown -R user:user /var/log/kafka

# Configure Kafka
print_status "Configuring Kafka server.properties..."
# Backup original configuration
if [ ! -f "/opt/kafka/config/server.properties.backup" ]; then
    cp /opt/kafka/config/server.properties /opt/kafka/config/server.properties.backup
fi

# Replace the server.properties with new configuration (not append)
cp /home/user/hadoop_tps/tp6/cfg/server.properties /opt/kafka/config/server.properties

# Modify node-specific settings
if [ "$node_name" == "slave1" ]; then
    print_status "Configuring Kafka for slave1..."
    sed -i 's/broker.id=1/broker.id=2/' /opt/kafka/config/server.properties
    sed -i 's/listeners=PLAINTEXT:\/\/master:9092/listeners=PLAINTEXT:\/\/slave1:9092/' /opt/kafka/config/server.properties
    sed -i 's/advertised.listeners=PLAINTEXT:\/\/master:9092/advertised.listeners=PLAINTEXT:\/\/slave1:9092/' /opt/kafka/config/server.properties
elif [ "$node_name" == "slave2" ]; then
    print_status "Configuring Kafka for slave2..."
    sed -i 's/broker.id=1/broker.id=3/' /opt/kafka/config/server.properties
    sed -i 's/listeners=PLAINTEXT:\/\/master:9092/listeners=PLAINTEXT:\/\/slave2:9092/' /opt/kafka/config/server.properties
    sed -i 's/advertised.listeners=PLAINTEXT:\/\/master:9092/advertised.listeners=PLAINTEXT:\/\/slave2:9092/' /opt/kafka/config/server.properties
fi

# Configure Kafka environment
print_status "Configuring Kafka environment..."
# Create kafka-server-start-env.sh if it doesn't exist
if [ ! -f "/opt/kafka/bin/kafka-server-start-env.sh" ]; then
    touch /opt/kafka/bin/kafka-server-start-env.sh
    chmod +x /opt/kafka/bin/kafka-server-start-env.sh
fi
# Append only if not already present
if ! grep -q "JAVA_HOME" /opt/kafka/bin/kafka-server-start-env.sh; then
    cat /home/user/hadoop_tps/tp6/cfg/kafka-server-start-env.sh >> /opt/kafka/bin/kafka-server-start-env.sh
fi

# Set up firewall rules
print_status "Configuring firewall rules..."
# ZooKeeper ports
sudo ufw allow 2181/tcp  # Client connections
sudo ufw allow 2888/tcp  # Follower connections  
sudo ufw allow 3888/tcp  # Election connections

# Kafka ports
sudo ufw allow 9092/tcp  # Kafka broker
sudo ufw allow 9999/tcp  # JMX monitoring

print_status "Firewall rules configured."

# Create systemd services
print_status "Creating systemd services..."

# ZooKeeper service
sudo tee /etc/systemd/system/zookeeper.service > /dev/null <<EOF
[Unit]
Description=Apache ZooKeeper
Documentation=http://zookeeper.apache.org
Requires=network.target remote-fs.target
After=network.target remote-fs.target

[Service]
Type=forking
User=user
Group=user
Environment=JAVA_HOME=$JAVA_HOME
ExecStart=/opt/zookeeper/bin/zkServer.sh start
ExecStop=/opt/zookeeper/bin/zkServer.sh stop
ExecReload=/opt/zookeeper/bin/zkServer.sh restart
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Kafka service  
sudo tee /etc/systemd/system/kafka.service > /dev/null <<EOF
[Unit]
Description=Apache Kafka
Documentation=http://kafka.apache.org
Requires=zookeeper.service
After=zookeeper.service

[Service]
Type=forking
User=user
Group=user
Environment=JAVA_HOME=$JAVA_HOME
Environment=KAFKA_HEAP_OPTS=-Xmx1G -Xms1G
ExecStart=/opt/kafka/bin/kafka-server-start.sh -daemon /opt/kafka/config/server.properties
ExecStop=/opt/kafka/bin/kafka-server-stop.sh
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd
sudo systemctl daemon-reload

# Enable services (but don't start them yet)
sudo systemctl enable zookeeper kafka

print_status "Systemd services created and enabled."

# Verification
print_status "Performing verification..."

# Check myid
if [ -f "/var/lib/zookeeper/myid" ]; then
    myid_content=$(cat /var/lib/zookeeper/myid)
    print_status "ZooKeeper myid: $myid_content"
else
    print_error "ZooKeeper myid file not found!"
fi

# Check Kafka broker.id
if [ -f "/opt/kafka/config/server.properties" ]; then
    broker_id=$(grep "broker.id=" /opt/kafka/config/server.properties | head -1)
    listeners=$(grep "listeners=" /opt/kafka/config/server.properties | head -1)
    print_status "Kafka $broker_id"
    print_status "Kafka $listeners"
else
    print_error "Kafka server.properties not found!"
fi
