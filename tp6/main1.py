""" Spark Streaming with Kafka in Cluster Mode"""


import findspark
findspark.init()


from pyspark import SparkContext, SparkConf
from pyspark.streaming import StreamingContext
from pyspark.streaming.kafka import KafkaUtils
from kafka import KafkaProducer, KafkaConsumer
from collections import Counter
import json

# Configure Spark for cluster mode
conf = SparkConf().setAppName("KafkaSparkStreaming")
# For cluster mode, remove local[2] and let cluster manager handle resource allocation
# conf.setMaster("yarn")  # Uncomment if using YARN
sc = SparkContext(conf=conf)
ssc = StreamingContext(sc, 1)

# Updated Kafka configuration for cluster
KAFKA_BOOTSTRAP_SERVERS = ['master:9092', 'slave1:9092', 'slave2:9092']
ZOOKEEPER_SERVERS = 'master:2181,slave1:2181,slave2:2181'

# Create Kafka topics with higher replication factor for cluster
def create_topics():
    """Create Kafka topics with replication for cluster setup"""
    import subprocess
    
    topics = ['input-event', 'output-event']
    for topic in topics:
        cmd = [
            '/opt/kafka/bin/kafka-topics.sh', '--create',
            '--topic', topic,
            '--bootstrap-server', ','.join(KAFKA_BOOTSTRAP_SERVERS),
            '--replication-factor', '2',  # Use 2 for 3-node cluster
            '--partitions', '3'
        ]
        subprocess.run(cmd, cwd='/path/to/kafka')

# Modified Kafka stream creation for cluster
def create_kafka_stream():
    """Create Kafka DStream for cluster setup"""
    kafkaParams = {
        "metadata.broker.list": ",".join(KAFKA_BOOTSTRAP_SERVERS),
        "group.id": "spark-streaming-group"
    }
    
    topics = ['input-event']
    kafkaStream = KafkaUtils.createDirectStream(
        ssc, 
        topics, 
        kafkaParams
    )
    return kafkaStream

# Word count processing function
def process_events(event):
    """Process events and return word count"""
    try:
        # event[1] contains the message value
        words = event[1].split(" ") if event[1] else []
        word_count = Counter(words).most_common(3)
        return (event[0] if event[0] else "unknown_key", word_count)
    except Exception as e:
        print(f"Error processing event: {e}")
        return ("error", [])

# Main processing pipeline
def setup_streaming_pipeline():
    """Setup the complete streaming pipeline"""
    
    # Create Kafka stream
    kafkaStream = create_kafka_stream()
    
    # Process the stream
    lines = kafkaStream.map(lambda x: process_events(x))
    
    # Setup Kafka producer for output (using cluster bootstrap servers)
    producer = KafkaProducer(
        bootstrap_servers=KAFKA_BOOTSTRAP_SERVERS,
        value_serializer=lambda v: json.dumps(v).encode('utf-8'),
        key_serializer=lambda k: str(k).encode('utf-8') if k else b'',
        # Additional cluster configurations
        acks='all',  # Wait for all replicas to acknowledge
        retries=3,
        batch_size=16384,
        linger_ms=10,
        buffer_memory=33554432
    )
    
    def push_back_to_kafka(rdd):
        """Push processed results back to Kafka"""
        def send_to_kafka(partition):
            for record in partition:
                try:
                    producer.send('output-event', 
                                key=record[0], 
                                value=record[1])
                    producer.flush()
                except Exception as e:
                    print(f"Error sending to Kafka: {e}")
        
        rdd.foreachPartition(send_to_kafka)
    
    # Apply the output operation
    lines.foreachRDD(push_back_to_kafka)
    
    # Print results locally as well
    lines.pprint()

# Producer function for testing
def produce_test_events():
    """Produce test events to Kafka cluster"""
    producer = KafkaProducer(
        bootstrap_servers=KAFKA_BOOTSTRAP_SERVERS,
        value_serializer=str.encode,
        key_serializer=str.encode,
        acks='all',
        retries=3
    )
    
    test_events = [
        ('product_list', 'product1 product2 product3 product1 product2'),
        ('user_activity', 'login logout login purchase view'),
        ('system_logs', 'error warning info error debug info')
    ]
    
    for key, value in test_events:
        producer.send('input-event', key=key, value=value)
        print(f"Sent: {key} -> {value}")
    
    producer.flush()
    producer.close()

# Consumer function for reading results
def consume_results():
    """Consume results from output topic"""
    consumer = KafkaConsumer(
        'output-event',
        bootstrap_servers=KAFKA_BOOTSTRAP_SERVERS,
        value_deserializer=lambda m: json.loads(m.decode('utf-8')),
        key_deserializer=lambda m: m.decode('utf-8') if m else None,
        group_id='result-consumer-group',
        auto_offset_reset='earliest'
    )
    
    print("Waiting for messages...")
    for message in consumer:
        print(f"Key: {message.key}, Value: {message.value}")
        print(f"Partition: {message.partition}, Offset: {message.offset}")

# Main execution
if __name__ == "__main__":
    try:
        # Setup the streaming pipeline
        setup_streaming_pipeline()
        
        # Start the streaming context
        ssc.start()
        
        print("Spark Streaming application started...")
        print("Kafka brokers:", KAFKA_BOOTSTRAP_SERVERS)
        print("Zookeeper ensemble:", ZOOKEEPER_SERVERS)
        
        # Wait for termination
        ssc.awaitTermination()
        
    except Exception as e:
        print(f"Error in main execution: {e}")
    finally:
        ssc.stop(stopSparkContext=True, stopGraceFully=True)
        sc.stop()