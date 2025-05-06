# Hadoop Cluster Setup Guide

This repository contains scripts and configuration files to set up a Hadoop cluster with master and slave nodes. This guide will walk you through the setup process, including SSH passwordless authentication configuration.

## Prerequisites

- Ubuntu/Debian-based Linux system
- Internet connection for downloading packages
- Basic understanding of Linux commands
- Multiple machines for cluster setup (or virtual machines)

## Repository Structure

- `setup.sh`: Main setup script that configures Hadoop based on node type
- Configuration files in `~/hadoop_tps/tp3/` directory:
  - `.bashrc`: Environment variables for Hadoop
  - `core-site.xml`: Core Hadoop configuration
  - `hdfs-master.xml`: HDFS configuration for master node
  - `hdfs-slaves.xml`: HDFS configuration for slave nodes
  - `yarn-master.xml`: YARN configuration for master node
  - `yarn-slaves.xml`: YARN configuration for slave nodes
  - `mapred-site.xml`: MapReduce configuration
  - `workers`: List of worker nodes

## Setup Instructions

### 1. Clone this Repository

```bash
git clone https://github.com/aplusInDev/hadoop_tps.git
```


### 2. Run the Setup Script


Make the setup script executable:
```bash
chmod u+x hadoop_tps/tp3/setup.sh
```

Execute the setup script with the appropriate node type:

For the master node:
```bash
source hadoop_tps/tp3/setup.sh master
```

For slave nodes:
```bash
source hadoop_tps/tp3/setup.sh slave
```

### 3. Configure SSH Passwordless Authentication


Configure /etc/hosts on all nodes to include the master and slave hostnames. For example:

```bash
# /etc/hosts
<master-ip> master-hostname
<slave-ip-1> slave-hostname-1
<slave-ip-2> slave-hostname-2
```
Replace `<master-ip>`, `<slave-ip-1>`, and `<slave-ip-2>` with the actual IP addresses of your nodes.

Then, run the following command on each node to set up passwordless SSH:

```bash
ssh-copy-id master-hostname
ssh-copy-id slave-hostname-1
ssh-copy-id slave-hostname-2
```

This will prompt for the password of the user on each node. After entering the password, SSH should work without a password.

### 4. Format HDFS (Master Node Only)

After running the setup script on all nodes, format the HDFS namenode on the master:

```bash
hdfs namenode -format
```

### 5. Start Hadoop Services

On the master node, start HDFS and YARN:

```bash
# Start HDFS
start-dfs.sh

# Start YARN
start-yarn.sh

```

### 6. Verify the Installation

Check if all services are running:

```bash
jps
```

On the master node, you should see:
- NameNode
- SecondaryNameNode
- ResourceManager
- JobHistoryServer

On slave nodes, you should see:
- DataNode
- NodeManager

### 7. Access Web Interfaces

- HDFS NameNode: http://master-hostname:9870
- YARN ResourceManager: http://master-hostname:8088

## Troubleshooting

### Common Issues:

1. **SSH Connection Failed**:
   - Check if SSH service is running: `sudo systemctl status ssh`
   - Verify permissions on `.ssh` directory and files
   - Ensure public keys are correctly added to `authorized_keys`

2. **Java Not Found**:
   - Verify Java installation: `java -version`
   - Check JAVA_HOME path in `hadoop-env.sh`

3. **Hadoop Services Not Starting**:
   - Check Hadoop logs in `$HADOOP_HOME/logs/`
   - Verify network connectivity between nodes
   - Ensure hostnames are correctly configured in `/etc/hosts`

4. **Permission Issues**:
   - Check user permissions for Hadoop directories
   - Ensure data directories specified in configs exist and are writable
5. **service not running**:
   - Check if the service is running using `jps` command
   - If not, check the logs in `$HADOOP_HOME/logs/` for errors
   - Restart the service using `stop-all.sh`, `start-dfs.sh` and `start-yarn.sh`

## Additional Notes

- The setup script installs Hadoop 3.4.0. If you want to use a different version, modify the script accordingly.
- For production environments, additional security configurations are recommended.
- This setup uses a simplified configuration suitable for learning purposes.

## References

- [Apache Hadoop Documentation](https://hadoop.apache.org/docs/r3.4.0/)
- [Hadoop: The Definitive Guide](https://www.oreilly.com/library/view/hadoop-the-definitive/9781491901687/)