#!/bin/bash

# turn on bash's job control
set -m

# Start the primary process and put it in the background
/opt/spark/bin/spark-class org.apache.spark.deploy.master.Master &

# Start the helper process
jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root --NotebookApp.token="${JUPYTERLAB_TOKEN}" --NotebookApp.password="${JUPYTERLAB_PASSWORD}"

# jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root --NotebookApp.token=admin --NotebookApp.password=admin
# the my_helper_process might need to know how to wait on the
# primary process to start before it does its work and returns


# now we bring the primary process back into the foreground
# and leave it there
fg %1