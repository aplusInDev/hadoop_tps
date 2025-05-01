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
# Extract Hadoop
tar xzf hadoop-3.4.0.tar.gz
# Copy Hadoop Configuration files
cat ~/hadoop_tps/tp1/cfg/.bashrc >> ~/.bashrc
source ~/.bashrc
which javac
# Set Hadoop environment variables
echo "export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh
cat ~/hadoop_tps/tp1/cfg/core-site.xml > $HADOOP_HOME/etc/hadoop/core-site.xml
cat ~/hadoop_tps/tp1/cfg/hdfs-site.xml > $HADOOP_HOME/etc/hadoop/hdfs-site.xml
cat ~/hadoop_tps/tp1/cfg/mapred-site.xml > $HADOOP_HOME/etc/hadoop/mapred-site.xml
cat ~/hadoop_tps/tp1/cfg/yarn-site.xml > $HADOOP_HOME/etc/hadoop/yarn-site.xml
# Format the HDFS namenode
hdfs namenode -format
# Start Hadoop services
start-dfs.sh
start-yarn.sh
# Check if Hadoop is running
jps
