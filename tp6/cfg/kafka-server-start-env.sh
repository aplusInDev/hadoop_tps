export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64  # Adjust path as needed
export KAFKA_HOME=/opt/kafka
export KAFKA_HEAP_OPTS="-Xmx1G -Xms1G"
export KAFKA_JVM_PERFORMANCE_OPTS="-server -XX:+UseG1GC -XX:MaxGCPauseMillis=20 -XX:InitiatingHeapOccupancyPercent=35"
