#!/bin/bash
docker build -t spark-hadoop:latest .

# docker build -t spark-jupyter:latest -f jupyterlab.Dockerfile .

# Reset MINIO_IP in .env.local
sed -i "s/^MINIO_IP=.*/MINIO_IP=localhost/" .env.local
docker-compose --profile minio up -d

## Add Minio IP to Jupyterlab for Spark Cluster to connect Minio (Spark application cannot use docker service name as hostname to connect)
MINIO_CONTAINER_NAME=minio
MINIO_CONTAINER_IP=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $MINIO_CONTAINER_NAME)

# Use sed to replace the IP address into .env.local file
sed -i "s/^MINIO_IP=.*/MINIO_IP=$MINIO_CONTAINER_IP/" .env.local

# docker-compose --profile spark up -d
docker-compose --profile spark --scale spark-worker=8 up -d

#Scale worker
# if [ -z "$1" ]
# then
#   docker-compose up --profile spark-cluster -d
# else
#   docker-compose up --profile spark-cluster --scale spark-worker=$1 -d
# fi

if [ -z "$1" ]
then
  echo "Hadoop is ignored"
else
  if [ "$1" == "hadoop" ]
  then 
    docker-compose -f docker-compose-hadoop.yaml up -d
  fi
fi

# COPY master-jupyter.sh /opt/workspace/master-jupyter.sh
# RUN chmod +x /opt/workspace/master-jupyter.sh
