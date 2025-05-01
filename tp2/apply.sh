hdfs dfs -mkdir -p /data/tp2/input
hdfs dfs -mkdir -p /data/tp2/output
hdfs dfs -copyFromLocal ~/tp2/meteosample.txt /data/tp2/input/

hadoop jar $HADOOP_HOME/share/hadoop/tools/lib/hadoop-streaming-*.jar \
    -file ~/tp2/mapper.py -mapper "python3 mapper.py" \
    -file ~/tp2/reducer.py -reducer "python3 reducer.py" \
    -input /data/tp2/input/meteosample.txt \
    -output /data/tp2/output

hdfs dfs -cat /data/tp2/output/part-00000
