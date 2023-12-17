# Create Spark Cluster with Docker and Read/Write data from Datalake:
## On-premise
* Hadoop
* MinIO
## Cloud
* Google Cloud Storage
* AWS S3
* Azure Blob Storage

## 🚀 About Me
I'm Danh, a Docker'fan :D

## Prerequisites

* Docker 

[Install Docker](https://docs.docker.com/engine/install/)

## Environment Variables

To Spark read/write from Cloud Datalake, you will need to add the following environment variables to your .env.local file
### Amazon Web Services
* `AWS_ACCESS_KEY_ID`
* `AWS_SECRET_ACCESS_KEY`
* `AWS_S3_BUCKET`
### Google Cloud Platform
* `GOOGLE_SERVICE_ACCOUNT_KEY_PATH`
* `GOOGLE_PROJECT_ID`
* `GOOGLE_STORAGE_BUCKET`
### Microsoft Azure
* `AZURE_STORAGE_ACCOUNT`
* `AZURE_STORAGE_CONTAINER`
* `AZURE_ACCESS_KEY`

## Spin up container

```bash
  cd docker-spark-datalake
  chmod +x docker_compose_up.sh
  ./docker_compose_up.sh
```

## Spin down container

```bash
  chmod +x docker_compose_down.sh
  ./docker_compose_down.sh
```
    
## Download sample data:

```bash
wget https://github.com/DataTalksClub/nyc-tlc-data/releases/download/yellow/yellow_tripdata_2021-01.csv.gz -O yellow_tripdata_2021-01.csv.gz
gunzip yellow_tripdata_2021-01.csv.gz
```






