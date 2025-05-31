from pyspark import SparkContext, SparkConf
from pyspark.streaming import StreamingContext
from pyspark.streaming.kafka import KafkaUtils
from kafka import KafkaProducer, KafkaConsumer
from collections import Counter
import json
import os
import sys

# 1. Spark Environment Setup (Run First)
def setup_spark():
    """Initialize Spark context - RUN THIS FIRST"""
    global sc, ssc
    
    # Configure environment
    os.environ['SPARK_HOME'] = '/opt/spark'
    os.environ['PYSPARK_PYTHON'] = sys.executable
    
    # Add PySpark to path
    spark_python = os.path.join(os.environ['SPARK_HOME'], 'python')
    py4j = os.path.join(spark_python, 'lib', 'py4j-*.zip')
    sys.path.extend([spark_python, py4j])
    
    # Create Spark context
    conf = SparkConf() \
        .setAppName("KafkaSparkStreaming") \
        .setMaster("spark://master:7077")
        
    sc = SparkContext(conf=conf)
    ssc = StreamingContext(sc, 1)  # 1-second batches
    print("✓ Spark initialized successfully!")

# 2. Kafka Configuration
KAFKA_BOOTSTRAP_SERVERS = ['master:9092', 'slave1:9092', 'slave2:9092']
ZOOKEEPER_SERVERS = 'master:2181,slave1:2181,slave2:2181'

# 3. Kafka Topic Management (Run Once)
def create_topics():
    """Create Kafka topics - RUN ONCE"""
    import subprocess
    kafka_bin = "/opt/kafka/bin"
    
    topics = ['input-event', 'output-event']
    for topic in topics:
        cmd = [
            f"{kafka_bin}/kafka-topics.sh", "--create",
            "--topic", topic,
            "--bootstrap-server", ",".join(KAFKA_BOOTSTRAP_SERVERS),
            "--replication-factor", "2",
            "--partitions", "3"
        ]
        result = subprocess.run(cmd, capture_output=True, text=True)
        print(f"Topic {topic}: {result.stdout or result.stderr}")

def delete_topics():
    """Delete Kafka topics - RUN WHEN DONE"""
    import subprocess
    kafka_bin = "/opt/kafka/bin"
    
    topics = ['input-event', 'output-event']
    for topic in topics:
        cmd = [
            f"{kafka_bin}/kafka-topics.sh", "--delete",
            "--topic", topic,
            "--bootstrap-server", ",".join(KAFKA_BOOTSTRAP_SERVERS)
        ]
        result = subprocess.run(cmd, capture_output=True, text=True)
        print(f"Delete {topic}: {result.stdout or result.stderr}")

# 4. Streaming Pipeline (Start/Stop)
def start_streaming():
    """Start Spark Streaming pipeline - RUN AFTER SETUP"""
    global producer_ref
    
    # Create Kafka stream
    kafkaParams = {"metadata.broker.list": ",".join(KAFKA_BOOTSTRAP_SERVERS)}
    kafkaStream = KafkaUtils.createDirectStream(ssc, ['input-event'], kafkaParams)
    
    # Process events
    def process_events(event):
        words = event[1].split() if event[1] else []
        return (event[0] or "unknown", Counter(words).most_common(3))
    
    processed = kafkaStream.map(process_events)
    
    # Output handler
    def send_to_kafka(partition):
        producer = KafkaProducer(
            bootstrap_servers=KAFKA_BOOTSTRAP_SERVERS,
            value_serializer=lambda v: json.dumps(v).encode(),
            key_serializer=lambda k: str(k).encode(),
            acks='all'
        )
        for record in partition:
            producer.send('output-event', key=record[0], value=record[1])
        producer.flush()
        producer.close()
    
    processed.foreachRDD(lambda rdd: rdd.foreachPartition(send_to_kafka))
    processed.pprint()  # Show in console
    
    ssc.start()
    print("Streaming started! Run stop_streaming() to terminate")

def stop_streaming():
    """Stop Spark Streaming - RUN WHEN DONE"""
    ssc.stop(stopSparkContext=False, stopGraceFully=True)
    print("Streaming stopped")

# 5. Test Functions (Run Anytime)
def send_test_message():
    """Send test message - RUN TO TEST"""
    producer = KafkaProducer(
        bootstrap_servers=KAFKA_BOOTSTRAP_SERVERS,
        value_serializer=str.encode,
        key_serializer=str.encode
    )
    producer.send('input-event', key='test', value='hello world spark kafka')
    producer.flush()
    print("✓ Test message sent")

def read_output():
    """Read output messages - RUN TO VERIFY"""
    consumer = KafkaConsumer(
        'output-event',
        bootstrap_servers=KAFKA_BOOTSTRAP_SERVERS,
        value_deserializer=json.loads,
        auto_offset_reset='earliest',
        consumer_timeout_ms=5000
    )
    print("Last 5 messages:")
    for i, msg in enumerate(consumer):
        if i >= 5: break
        print(f"Key: {msg.key}, Value: {msg.value}")