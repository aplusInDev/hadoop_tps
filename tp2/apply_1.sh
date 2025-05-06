hdfs dfs -mkdir -p /data/tp2/input_1
hdfs dfs -copyFromLocal ~/hadoop_tps/tp2/meteosample.txt /data/tp2/input_1/

hadoop jar $HADOOP_HOME/share/hadoop/tools/lib/hadoop-streaming-*.jar \
  -files ~/hadoop_tps/tp2/mapper_1.py,~/hadoop_tps/tp2/reducer_1.py \
  -mapper "python3 mapper_1.py" \
  -reducer "python3 reducer_1.py" \
  -input /data/tp2/input_1/* \
  -output /output_1

echo "Results: ------------------";
hdfs dfs -cat /output_1/part-*

hdfs dfs -rm -r /output_1
hdfs dfs -rm -r /data/tp2/
