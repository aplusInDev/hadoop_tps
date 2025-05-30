#!/bin/bash

echo "Stopping Kafka..."
sudo systemctl stop kafka

echo "Stopping ZooKeeper..."  
sudo systemctl stop zookeeper

echo "Cluster shutdown completed!"
