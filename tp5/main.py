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
from pyspark.sql.functions import (
    col, countDistinct, avg, round, sum as sql_sum, row_number
)
from pyspark.sql.window import Window

# Initialisation de SparkSession
spark = SparkSession.builder \
    .appName("TP5 PySpark") \
    .getOrCreate()

# Chargement des données
# Note: Remplacer les chemins selon votre configuration
sales_df = spark.read.parquet("/data/sales_parquet")
products_df = spark.read.parquet("/data/products_parquet")
sellers_df = spark.read.parquet("/data/sellers_parquet")

# Affichage des schémas
print("Schéma de la table Sales:")
sales_df.printSchema()

print("Schéma de la table Products:")
products_df.printSchema()

print("Schéma de la table Sellers:")
sellers_df.printSchema()

# Affichage des premières lignes
print("Aperçu de la table Sales:")
sales_df.show(5)

print("Aperçu de la table Products:")
products_df.show(5)

print("Aperçu de la table Sellers:")
sellers_df.show(5)

# Question 1 de l'exemple: Combien de commandes, de produits et de vendeurs
num_orders = sales_df.count()
num_products = products_df.count()
num_sellers = sellers_df.count()

print(f"Nombre de commandes: {num_orders}")
print(f"Nombre de produits: {num_products}")
print(f"Nombre de vendeurs: {num_sellers}")

# Question 2 de l'exemple: Produits distincts vendus chaque jour
daily_products = sales_df.groupby(col("date")) \
                         .agg(countDistinct(col("product_id")).alias("distinct_products_sold")) \
                         .orderBy(col("distinct_products_sold").desc())

# print("Nombre de produits distincts vendus par jour:")
# sales_df.groupby(col("date"))\
#     .agg(countDistinct(col("product_id")).alias("distinct_products_sold"))\
#         .orderBy(col("distinct_products_sold").desc())\
#             .show()

print("Nombre de produits distincts vendus par jour:")
daily_products.show()

# Travail à faire

# Question 1: Revenu moyen des commandes
print("\n--- Question 1: Revenu moyen des commandes ---")

# Jointure des tables sales et products pour obtenir le prix
sales_with_products = sales_df.join(products_df, "product_id")

# Calcul du revenu par commande (prix * quantité)
sales_with_revenue = sales_with_products.withColumn("revenue", col("price") * col("num_pieces_sold"))

# Calcul du revenu moyen
avg_revenue = sales_with_revenue.agg(round(avg("revenue"), 2).alias("average_order_revenue"))

print("Le revenu moyen des commandes est:")
avg_revenue.show()

# Question 2: Contribution moyenne aux quotas des vendeurs
print("\n--- Question 2: Contribution moyenne aux quotas des vendeurs ---")

# Jointure des tables sales et sellers
sales_with_sellers = sales_df.join(sellers_df, "seller_id")

# Calcul du pourcentage de contribution pour chaque commande
contribution_df = sales_with_sellers.withColumn(
    "contribution_percentage", 
    (col("num_pieces_sold") / col("daily_target"))
)

# Calcul de la contribution moyenne par vendeur
avg_contribution_by_seller = contribution_df.groupBy("seller_id", "seller_name") \
    .agg(round(avg("contribution_percentage") * 100, 4).alias("avg_contribution_percent")) \
    .orderBy("seller_id")

print("Contribution moyenne en % d'une commande au quota quotidien par vendeur:")
avg_contribution_by_seller.show()

# Question 3: Meilleur et pire vendeur pour chaque produit
print("\n--- Question 3: Meilleur et pire vendeur par produit ---")

# Calcul du nombre total d'unités vendues par vendeur pour chaque produit
sales_by_product_seller = sales_df.groupBy("product_id", "seller_id") \
    .agg(sql_sum("num_pieces_sold").alias("total_sold"))

# Jointure avec les noms des vendeurs
sales_by_product_seller = sales_by_product_seller.join(sellers_df, "seller_id")

# Définition de la fenêtre par produit (ordre décroissant pour le meilleur vendeur)
window_spec_desc = Window.partitionBy("product_id").orderBy(col("total_sold").desc())

# Ajout du rang pour chaque vendeur par produit
ranked_sellers_desc = sales_by_product_seller.withColumn("rank", row_number().over(window_spec_desc))

# Sélection du meilleur vendeur (rang 1)
best_sellers = ranked_sellers_desc.filter(col("rank") == 1) \
    .select("product_id", 
            col("seller_id").alias("best_seller_id"), 
            col("seller_name").alias("best_seller_name"),
            col("total_sold").alias("best_seller_units"))

# Définition de la fenêtre par produit (ordre croissant pour le pire vendeur)
window_spec_asc = Window.partitionBy("product_id").orderBy(col("total_sold").asc())
ranked_sellers_asc = sales_by_product_seller.withColumn("rank", row_number().over(window_spec_asc))

# Sélection du pire vendeur (rang 1 en ordre croissant)
worst_sellers = ranked_sellers_asc.filter(col("rank") == 1) \
    .select("product_id", 
            col("seller_id").alias("worst_seller_id"), 
            col("seller_name").alias("worst_seller_name"),
            col("total_sold").alias("worst_seller_units"))

# Jointure des résultats pour obtenir le meilleur et le pire vendeur par produit
final_result = best_sellers.join(worst_sellers, "product_id").orderBy("product_id")

print("Meilleur et pire vendeur par produit:")
final_result.show()

# Arrêt de la session Spark
spark.stop()

