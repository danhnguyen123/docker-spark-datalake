# ARG debian_buster_image_tag=8-jre-slim
FROM bitnami/spark:3.3.0

# -- Layer: JupyterLab
USER root

ARG shared_workspace=/opt/workspace
ARG spark_version=3.3.0
ARG jupyterlab_version=4.0.9
# ARG jupyter_token=danhnguyen123

RUN mkdir -p ${shared_workspace} && \
    apt-get update -y && \
    apt-get install -y python3 && \
    apt-get install -y python3-pip && \
    pip3 install wget pyspark==${spark_version} jupyterlab==${jupyterlab_version}

# install dependencies
RUN pip install --upgrade pip
COPY ./requirements.txt .
RUN pip install -r requirements.txt

# -- Runtime

EXPOSE 8888
WORKDIR ${shared_workspace}
CMD jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root --NotebookApp.token=danhnguyen123 --NotebookApp.password=danhnguyen56