#!/bin/bash
docker-compose --profile minio down
docker-compose --profile spark-cluster down

if [ -z "$1" ]
then
  echo "Hadoop is ignored"
else
  if [ "$1" == "hadoop" ]
  then 
    docker-compose -f docker-compose-hadoop.yaml down
  fi
fi
