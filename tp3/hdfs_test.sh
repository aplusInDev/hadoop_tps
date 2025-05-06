# Création d'un répertoire dans HDFS
hdfs dfs -mkdir -p /tp3/test
echo "hello world!" > test_hdfs.txt
hdfs dfs -put test_hdfs.txt /tp3/test
# Vérification du fichier et de sa réplication
hdfs dfs -ls /tp3/test
Found 1 items
-rw-r--r--   2 user supergroup         13 2025-05-06 15:55 /tp3/test/test_hdfs.txt
hdfs fsck /tp3/test/test_hdfs.txt -files -blocks -locations
