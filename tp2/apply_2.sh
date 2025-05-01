hdfs dfs -mkdir -p /data/tp2/input
hdfs dfs -copyFromLocal ~/tp2/meteosample.txt /data/tp2/input/

hadoop jar $HADOOP_HOME/share/hadoop/tools/lib/hadoop-streaming-*.jar \
    -file ~/tp2/mapper_2.py -mapper "python3 mapper_2.py" \
    -file ~/tp2/reducer_2.py -reducer "python3 reducer_2.py" \
    -input /data/tp2/input/* \
    -output /output_2

hdfs dfs -cat /output/part-00000
hdfs dfs -rm -r /output_2
hdfs dfs -rm -r /tp2
