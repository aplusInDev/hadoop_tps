if [ $# -eq 0 ] || ([ "$1" != "master" ] && [ "$1" != "slave" ]); then
    echo "Usage: $0 [master|slave]"
    exit 1
fi

node_type=$1

# setting up Hadoop

# Check for updates
sudo apt update
# Install Java
sudo apt install -y openjdk-11-jdk
# Check Java installation
java -version; javac -version
# Install SSH
sudo apt install openssh-server openssh-client -y
# Create SSH keys
ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
# Copy public key to authorized_keys
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
# Test SSH connection
# ssh localhost
# Install Hadoop
wget https://dlcdn.apache.org/hadoop/common/hadoop-3.4.0/hadoop-3.4.0.tar.gz

if [ $? -ne 0 ]; then
    echo "Failed to download Hadoop. Please check your internet connection."
    exit 1
fi
# Extract Hadoop
tar xzf hadoop-3.4.0.tar.gz
# Copy Hadoop Configuration files
cat ~/hadoop_tps/tp3/.bashrc >> ~/.bashrc
source ~/.bashrc
which javac
# Set Hadoop environment variables
echo "export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh
cat ~/hadoop_tps/tp3/core-site.xml > $HADOOP_HOME/etc/hadoop/core-site.xml
if [ "$node_type" == "master" ]; then
    cat ~/hadoop_tps/tp3/hdfs-master.xml > $HADOOP_HOME/etc/hadoop/hdfs-site.xml
    cat ~/hadoop_tps/tp3/yarn-master.xml > $HADOOP_HOME/etc/hadoop/yarn-site.xml
    cat ~/hadoop_tps/tp3/workers >> $HADOOP_HOME/etc/hadoop/workers
elif [ "$node_type" == "slave" ]; then
    cat ~/hadoop_tps/tp3/hdfs-slaves.xml > $HADOOP_HOME/etc/hadoop/hdfs-site.xml
    cat ~/hadoop_tps/tp3/yarn-slaves.xml > $HADOOP_HOME/etc/hadoop/yarn-site.xml
fi
cat ~/hadoop_tps/tp3/mapred-site.xml > $HADOOP_HOME/etc/hadoop/mapred-site.xml
