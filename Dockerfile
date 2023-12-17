FROM python:3.10-bullseye
LABEL python_version=python3.10
# why bullseye ? because it will have Java 11 - openjdk-11-jdk for launching Spark (Spark required Java 8 or 11)
LABEL debian=bullseye
# Add Dependencies for Spark
RUN apt-get update && apt-get install -y curl vim wget software-properties-common ssh net-tools ca-certificates rsync openjdk-11-jdk-headless

# Fix the value of PYTHONHASHSEED
# Note: this is needed when you use Python 3.3 or greater
ENV SPARK_VERSION=3.3.0 \
HADOOP_VERSION=3.3.5 \
JUPYTER_VERSION=4.0.9 \
PYTHONHASHSEED=1

#Install Spark
RUN wget -O apache-spark.tgz "https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-without-hadoop.tgz" \
&& mkdir -p /opt/spark \
&& tar -xf apache-spark.tgz -C /opt/spark --strip-components=1 \
&& rm apache-spark.tgz

#Install Hadoop
RUN wget -O hadoop.tgz "https://dlcdn.apache.org/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz" \
&& mkdir -p /opt/hadoop \
&& tar -xf hadoop.tgz -C /opt/hadoop --strip-components=1 \
&& rm hadoop.tgz

ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64

ENV SPARK_MASTER_PORT=7077 \
SPARK_MASTER_WEBUI_PORT=8080 \
SPARK_LOG_DIR=/opt/spark/logs \
SPARK_MASTER_LOG=/opt/spark/logs/spark-master.out \
SPARK_WORKER_LOG=/opt/spark/logs/spark-worker.out \
SPARK_WORKER_WEBUI_PORT=8080 \
SPARK_WORKER_PORT=7000 \
SPARK_MASTER_URL="spark://spark-master:7077"

ENV HADOOP_HOME=/opt/hadoop
ENV SPARK_HOME=/opt/spark
ENV PATH=$SPARK_HOME/bin:$HADOOP_HOME/bin:$PATH

# AWS + Minio connector 
# Already have hadoop-aws: /opt/hadoop/share/hadoop/tools/lib/hadoop-aws-3.3.5.jar
ENV HADOOP_OPTIONAL_TOOLS="hadoop-aws"

# Google Cloud Connector
RUN wget https://storage.googleapis.com/hadoop-lib/gcs/gcs-connector-hadoop3-latest.jar -O /opt/spark/jars/gcs-connector.jar 
ENV GCP_LIB=/opt/spark/jars/gcs-connector.jar

# Micrsoft Azure Blob Connector
# Already have hadoop-azure: /opt/hadoop/share/hadoop/tools/lib/hadoop-azure-3.3.5.jar
RUN wget https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-azure/3.3.5/hadoop-azure-3.3.5.jar -O /opt/spark/jars/hadoop-azure-3.3.5.jar
RUN wget https://repo1.maven.org/maven2/com/microsoft/azure/azure-storage/7.0.1/azure-storage-7.0.1.jar -O /opt/spark/jars/azure-storage-7.0.1.jar
RUN wget https://repo1.maven.org/maven2/com/azure/azure-storage-blob/12.14.1/azure-storage-blob-12.14.1.jar -O /opt/spark/jars/azure-storage-blob-12.14.1.jar
ENV AZURE_LIB=/opt/spark/jars/hadoop-azure-3.3.5.jar:/opt/spark/jars/azure-storage-7.0.1.jar:/opt/spark/jars/azure-storage-blob-12.3.0.jar

# Add classpath jar lib to Hadoop 
RUN echo "export HADOOP_CLASSPATH=\$HADOOP_CLASSPATH:\$(hadoop classpath):$GCP_LIB:$AZURE_LIB" >> /opt/hadoop/etc/hadoop/hadoop-env.sh

# Add classpath jar lib to Spark 
RUN mv /opt/spark/conf/spark-env.sh.template /opt/spark/conf/spark-env.sh \
    && echo "export SPARK_DIST_CLASSPATH=\$(hadoop classpath):$GCP_LIB:$AZURE_LIB" >> /opt/spark/conf/spark-env.sh

# ENV SPARK_DIST_CLASSPATH=/opt/hadoop/etc/hadoop:/opt/hadoop/share/hadoop/common/lib/*:/opt/hadoop/share/hadoop/common/*:/opt/hadoop/share/hadoop/tools/lib/aws-java-sdk-bundle-1.12.316.jar:/opt/hadoop/share/hadoop/tools/lib/hadoop-aws-3.3.5.jar:/opt/hadoop/share/hadoop/hdfs:/opt/hadoop/share/hadoop/hdfs/lib/*:/opt/hadoop/share/hadoop/hdfs/*:/opt/hadoop/share/hadoop/mapreduce/*:/opt/hadoop/share/hadoop/yarn:/opt/hadoop/share/hadoop/yarn/lib/*:/opt/hadoop/share/hadoop/yarn/* 
# export SPARK_DIST_CLASSPATH=$(hadoop classpath)
# RUN echo "export SPARK_DIST_CLASSPATH=\$(hadoop classpath):$GCS_CONNECTOR" >> ~/.bashrc

RUN mkdir -p $SPARK_LOG_DIR && \
touch $SPARK_MASTER_LOG && \
touch $SPARK_WORKER_LOG && \
ln -sf /dev/stdout $SPARK_MASTER_LOG && \
ln -sf /dev/stdout $SPARK_WORKER_LOG

RUN apt-get update -y && \
    # apt-get install -y python3 && \
    # apt-get install -y python3-pip && \
    pip3 install wget pyspark==${SPARK_VERSION} jupyterlab==${JUPYTER_VERSION}

# install dependencies
RUN pip install --upgrade pip
COPY ./requirements.txt .
RUN pip install -r requirements.txt

# For Spark
EXPOSE 8080 7077 7000

# For Jupyter Lab
EXPOSE 8888
# COPY start-spark.sh /

RUN mkdir -p /opt/workspace && chmod 777 -R /opt/workspace
WORKDIR /opt/workspace

# References:
# https://github.com/fithisux/spark-standalone-with-minio/blob/main/spark-access-minio.py
# https://github.com/eco-minio/cookbook/blob/master/docs/apache-spark-with-minio.md