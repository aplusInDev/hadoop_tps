$KAFKA_HOME/bin/kafka-console-consumer.sh \
  --topic test-topic \
  --bootstrap-server master:9092,slave1:9092,slave2:9092 \
  --from-beginning
