# Hadoop Installation and Configuration Guide

This repository contains scripts and configuration files for setting up Apache Hadoop 3.4.0 on Ubuntu systems.

## Table of Contents
- [Prerequisites](#prerequisites)
- [Quick Setup Guide](#quick-setup-guide)
- [Configuration Details](#configuration-details)
- [Directory Structure](#directory-structure)
- [Checking Hadoop Services](#checking-hadoop-services)
- [Common Issues and Troubleshooting](#common-issues-and-troubleshooting)
- [Additional Resources](#additional-resources)

## Prerequisites

- Ubuntu Server (24.04.2 recommended)
- VM Virtual Box or similar virtualization software
- Internet connection to download packages
- Sufficient disk space (at least 5GB free)

## Quick Setup Guide

Follow these steps to quickly set up Hadoop on your system:

### 1. Clone the Repository

```bash
git clone https://github.com/aplusInDev/hadoop_tps
```

### 2. Make the Setup Script Executable

```bash
chmod u+x ./hadoop_tps/tp1/setup.sh
```

### 3. Run the Setup Script

```bash
source ./hadoop_tps/tp1/setup.sh
```

This script will:
- Update package repositories
- Install OpenJDK 11
- Configure SSH for passwordless authentication
- Download and extract Hadoop 3.4.0
- Set up all required configuration files
- Format the HDFS NameNode
- Start Hadoop services (HDFS and YARN)

### 4. Verify Installation

After setup completes successfully, you can access the web interfaces:

- NameNode interface: [http://localhost:9870](http://localhost:9870) or `http://<VM-address>:9870`
- ResourceManager interface: [http://localhost:8088](http://localhost:8088)

## Configuration Details

The setup includes configuration of the following key files:

- **core-site.xml**: General Hadoop configuration
- **hdfs-site.xml**: HDFS-specific settings
- **mapred-site.xml**: MapReduce configuration
- **yarn-site.xml**: YARN resource manager settings

## Directory Structure

The setup creates the following directory structure:

```
/home/user/
├── hadoop-3.4.0/           # Hadoop installation directory
├── tmpdata/                # Hadoop temporary data
└── dfsdata/                # HDFS data storage
    ├── namenode/           # NameNode data directory
    └── datanode/           # DataNode data directory
```

## Checking Hadoop Services

To verify that all Hadoop services are running correctly, use the following command:

```bash
jps
```

You should see the following processes:
- NameNode
- DataNode
- SecondaryNameNode
- ResourceManager
- NodeManager

## Common Issues and Troubleshooting

### Java Path Issues
If you encounter errors related to Java, verify your JAVA_HOME path:
```bash
echo $JAVA_HOME
```

### SSH Connection Issues
If Hadoop services fail to start due to SSH issues:
```bash
ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
ssh localhost  # Test the connection
```

### Service Restart
If you need to restart Hadoop services:
```bash
stop-dfs.sh
stop-yarn.sh
start-dfs.sh
start-yarn.sh
```

### HDFS Format Issues
If you need to reformat the NameNode (WARNING: This will delete all data in HDFS):
```bash
hdfs namenode -format
```

## Additional Resources

- [Apache Hadoop Documentation](https://hadoop.apache.org/docs/r3.4.0/)
- [HDFS Commands Guide](https://hadoop.apache.org/docs/r3.4.0/hadoop-project-dist/hadoop-common/FileSystemShell.html)
