THRESHOLD=0

hdfs dfs -mkdir -p /data/tp2/input_2
hdfs dfs -copyFromLocal ~/hadoop_tps/tp2/meteosample.txt /data/tp2/input_2/

hadoop jar $HADOOP_HOME/share/hadoop/tools/lib/hadoop-streaming-*.jar \
    -files ~/hadoop_tps/tp2/mapper_2.py,~/hadoop_tps/tp2/reducer_2.py \
    -mapper "python3 mapper_2.py $THRESHOLD" \
    -reducer "python3 reducer_2.py" \
    -input /data/tp2/input_2/* \
    -output /output_2

echo "Results for Months with Temperature > $THRESHOLD: ------------------";
hdfs dfs -cat /output_2/part-*

hdfs dfs -rm -r /output_2
hdfs dfs -rm -r /data/tp2/
