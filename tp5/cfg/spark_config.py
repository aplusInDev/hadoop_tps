import os
import sys

def init_spark():
    # Set Spark environment variables
    os.environ['SPARK_HOME'] = '/opt/spark'  # Replace with your actual Spark path
    os.environ['PYSPARK_PYTHON'] = sys.executable
    
    # Add PySpark to Python path
    spark_python = os.path.join(os.environ['SPARK_HOME'], 'python')
    py4j = os.path.join(spark_python, 'lib', 'py4j-0.10.9.7-src.zip')
    sys.path.insert(0, spark_python)
    sys.path.insert(0, py4j)
    
    print("Spark environment initialized")

# Auto-initialize when imported
init_spark()