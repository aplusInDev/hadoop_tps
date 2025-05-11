import os
import sys

# Set Spark environment variables
os.environ['SPARK_HOME'] = '/opt/spark'  # Replace with your actual Spark path
os.environ['PYSPARK_PYTHON'] = sys.executable

# Add PySpark to Python path
spark_python = os.path.join(os.environ['SPARK_HOME'], 'python')
py4j = os.path.join(spark_python, 'lib', 'py4j-0.10.9.7-src.zip')
sys.path.insert(0, spark_python)
sys.path.insert(0, py4j)


from pyspark.sql import SparkSession


spark_session = SparkSession.builder.appName("Test").getOrCreate()
sc = spark_session.sparkContext

tempsFile = sc.textFile("hdfs:///data/meteosample.txt")
tempsResults = tempsFile.flatMap(lambda line : line.split("\n"))\
    .map(lambda line : (line.split(" : ")[2], float(line.split(" : ")[3])))\
        .reduceByKey(max)
        
for result in tempsResults.collect():
    print(result)
