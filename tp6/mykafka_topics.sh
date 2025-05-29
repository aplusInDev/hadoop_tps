# Create a test topic
$KAFKA_HOME/bin/kafka-topics.sh --create \
  --topic test-topic \
  --bootstrap-server master:9092,slave1:9092,slave2:9092 \
  --partitions 3 \
  --replication-factor 3

# List topics
$KAFKA_HOME/bin/kafka-topics.sh --list --bootstrap-server master:9092

# Describe topic
$KAFKA_HOME/bin/kafka-topics.sh --describe --topic test-topic --bootstrap-server master:9092
