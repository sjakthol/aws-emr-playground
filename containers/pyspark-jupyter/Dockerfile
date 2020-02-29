ARG AWS_ACCOUNT_ID
ARG AWS_REGION
ARG DEPLOYMENT_NAME

FROM ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${DEPLOYMENT_NAME}/pyspark-runtime:base

# Install JupyterLab & friends
RUN python3 -m pip --no-cache-dir install jupyterlab s3contents

# Make sure Jupyter can find its config
ENV HOME /tmp
RUN mkdir /tmp/.jupyter/
COPY jupyter_notebook_config.py /tmp/.jupyter/

# Configure notebook bucket for this deployment
ARG DEPLOYMENT_NAME
RUN sed -i s/DEPLOYMENT_NAME/${DEPLOYMENT_NAME}/ /tmp/.jupyter/jupyter_notebook_config.py

ENV PYSPARK_PYTHON python3
ENV PYSPARK_DRIVER_PYTHON jupyter
ENV PYSPARK_DRIVER_PYTHON_OPTS "lab --no-browser --log-level=INFO --ip 0.0.0.0 --allow-root"
EXPOSE 8888
