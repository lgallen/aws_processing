# This script can be used to read parquet files from S3 to an EC2 instance using SparklyR in local mode.
# This can be useful if your data resides in Parquet format and is not so large as to require an EMR 
# cluster. Parquet files are very efficient, both due to compression and their columnar format.

# Script assumes installation of Java, SparklyR, and Spark 2.0.1.

library(sparklyr)
library(dplyr)

# Set environment variables
Sys.setenv(AWS_ACCESS_KEY_ID="")
Sys.setenv(AWS_SECRET_ACCESS_KEY="")
Sys.setenv(SPARK_HOME="/opt/spark")
Sys.setenv(JAVA_HOME='/usr/lib/jvm/java-8-oracle')
Sys.setenv("SPARK_MEM" = "55g")

# Spark configuration-found by trial and error. Not necessarily very optimal.
config <- spark_config()
config$sparklyr.defaultPackages <- "org.apache.hadoop:hadoop-aws:2.7.3"
config$spark.driver.memory <- "15g"
config$spark.driver.maxResultSize <- "15g"
config$spark.driver.extraJavaOptions <- "append -XX:MaxPermSize=15G"
sc <- spark_connect(master = "local", config = config, version = "2.0.1")

# Test spark context with iris dataset
iris_tbl <- copy_to(sc, iris)
head(iris_tbl)

# Read data from S3
spark_df <- spark_read_parquet(sc, "name", path = "s3a://s3_folder/s3_parquet_file", memory = TRUE)

# Example dplyr call
row_counts <- spark_df %>% group_by(interesting_column) %>% summarise(observations = n())
