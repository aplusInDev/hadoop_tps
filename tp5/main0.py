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


# from pyspark import SparkContext, SparkConf

# # Configuration de l'application Spark
# conf = SparkConf().setAppName("WordCount").setMaster("local")
# sc = SparkContext(conf=conf)

from pyspark.sql import SparkSession


spark_session = SparkSession.builder.appName("Test").getOrCreate()
sc = spark_session.sparkContext

text = sc.textFile("hdfs:///data/pg20417.txt")

counts = text.flatMap(lambda line: line.split(" ")) \
             .map(lambda word: (word, 1)) \
             .reduceByKey(lambda a, b: a + b)


for elt in counts.take(10):
    print(elt)

# counts.saveAsTextFile("hdfs:///output_test")

