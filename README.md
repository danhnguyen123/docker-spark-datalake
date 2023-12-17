Download sample data:

wget https://github.com/DataTalksClub/nyc-tlc-data/releases/download/yellow/yellow_tripdata_2021-01.csv.gz -O yellow_tripdata_2021-01.csv.gz
gunzip yellow_tripdata_2021-01.csv.gz

Tear up infrastructure 
cd docker-spark-datalake
chmod +x docker_compose_up.sh
./docker_compose_up.sh

Tear down infrastructure 
chmod +x docker_compose_down.sh
./docker_compose_down.sh






