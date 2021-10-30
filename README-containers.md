# Obsolete - Not updated since first EMR 6 Beta

This document is mostly out of date. Kept here for future reference.

### EMR 6.0.0 Beta

EMR 6.0.0 Beta allows Spark applications to be executed inside Docker container. Use the following
commands to build a runtime image for PySpark scripts:
```bash
cd containers/pyspark-runtime/ && make login build push
```
Next, setup an EMR cluster using the `emr-6.0.0-beta2` version by changing the `ReleaseLabel` parameter value
in `cluster.yaml`.

#### Docker Configuration & ECR Credentials

Spark requires credentials to pull images from ECR. Currently, these credentials must be supplied in a
Docker configuration file stored in HDFS storage of the EMR cluster. Use the following credentials to
prepare the Docker configuration:

```bash
aws --region eu-west-1 ecr get-login --no-include-email | sed "s/docker/sudo docker/g" | bash
mkdir -p ~/.docker && sudo cp /root/.docker/config.json ~/.docker && sudo chown hadoop ~/.docker/config.json
hadoop fs -put ~/.docker/config.json /user/hadoop/
```

Docker configuration with credentials to pull images from ECR are now available in
`hdfs:///user/hadoop/config.json`

#### Running PySpark Applications

SSH into master node and run the following commands to execute a PySpark script (`main.py`) inside
the pyspark-runtime container:
```bash
ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
DOCKER_IMAGE_NAME=$ACCOUNT.dkr.ecr.eu-west-1.amazonaws.com/ew1-emr-default/pyspark-runtime:base
DOCKER_CLIENT_CONFIG=hdfs:///user/hadoop/config.json
spark-submit --master yarn \
    --deploy-mode cluster \
    --conf spark.executorEnv.YARN_CONTAINER_RUNTIME_TYPE=docker \
    --conf spark.executorEnv.YARN_CONTAINER_RUNTIME_DOCKER_IMAGE=$DOCKER_IMAGE_NAME \
    --conf spark.executorEnv.YARN_CONTAINER_RUNTIME_DOCKER_CLIENT_CONFIG=$DOCKER_CLIENT_CONFIG \
    --conf spark.executorEnv.YARN_CONTAINER_RUNTIME_DOCKER_MOUNTS=/etc/passwd:/etc/passwd:ro \
    --conf spark.yarn.appMasterEnv.YARN_CONTAINER_RUNTIME_TYPE=docker \
    --conf spark.yarn.appMasterEnv.YARN_CONTAINER_RUNTIME_DOCKER_IMAGE=$DOCKER_IMAGE_NAME \
    --conf spark.yarn.appMasterEnv.YARN_CONTAINER_RUNTIME_DOCKER_CLIENT_CONFIG=$DOCKER_CLIENT_CONFIG \
    --conf spark.yarn.appMasterEnv.YARN_CONTAINER_RUNTIME_DOCKER_MOUNTS=/etc/passwd:/etc/passwd:ro \
    main.py -v
```

You can find the application logs by using the YARN CLI:
```bash
yarn logs -applicationId <app_id_from_spark-submit_output>
```

Here's a simple `main.py` that can be used to test if the setup works:
```python
from pyspark.sql import SparkSession
spark = SparkSession.builder.appName("docker-numpy").getOrCreate()

import numpy as np
a = np.arange(15).reshape(3, 5)

print(a)
```

#### Interactive Spark Shell via Jupyter in Docker

**DANGER, DANGER! HACKS AHEAD! DO NOT TRY THIS AT HOME!**

If you wanted to get an interactive JupyterLab session into Spark running in Docker, you could do the following:

1. Build JupyterLab container:
```bash
cd containers/pyspark-jupyter/ && make login build push
```

2. SSH to EMR master node and create a file called `jupyter.py` with the following contents:
```python
import sys
import os
os.environ['HOME'] = '/tmp'
sys.argv = ["jupyter", "lab", "--no-browser", "--log-level=INFO", "--ip", "0.0.0.0", "--allow-root"]

from jupyter_core.command import main
sys.exit(main())
```

3. Run `jupyter.py` as a Spark application:
```
ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
DOCKER_IMAGE_NAME=$ACCOUNT.dkr.ecr.eu-west-1.amazonaws.com/ew1-emr-default/pyspark-runtime:jupyter
DOCKER_CLIENT_CONFIG=hdfs:///user/hadoop/config.json
spark-submit --master yarn \
    --deploy-mode cluster \
    --conf spark.executorEnv.YARN_CONTAINER_RUNTIME_TYPE=docker \
    --conf spark.executorEnv.YARN_CONTAINER_RUNTIME_DOCKER_IMAGE=$DOCKER_IMAGE_NAME \
    --conf spark.executorEnv.YARN_CONTAINER_RUNTIME_DOCKER_CLIENT_CONFIG=$DOCKER_CLIENT_CONFIG \
    --conf spark.executorEnv.YARN_CONTAINER_RUNTIME_DOCKER_MOUNTS=/etc/passwd:/etc/passwd:ro \
    --conf spark.yarn.appMasterEnv.YARN_CONTAINER_RUNTIME_TYPE=docker \
    --conf spark.yarn.appMasterEnv.YARN_CONTAINER_RUNTIME_DOCKER_IMAGE=$DOCKER_IMAGE_NAME \
    --conf spark.yarn.appMasterEnv.YARN_CONTAINER_RUNTIME_DOCKER_CLIENT_CONFIG=$DOCKER_CLIENT_CONFIG \
    --conf spark.yarn.appMasterEnv.YARN_CONTAINER_RUNTIME_DOCKER_MOUNTS=/etc/passwd:/etc/passwd:ro \
    jupyter.py
```

4. Figure out which worked node did the Spark Driver program land on and create an SSH tunnel to
   port 8888 on said node:
```
ssh -L localhost:8888:localhost:8888 hadoop@<spark-driver-instance>
```

5. Access Jupyter on http://localhost:8888 and execute the following code in a notebook to finalize the
initialization of Spark Driver (be fast as Spark crashes if a session is not created soon after
launch):
```
from pyspark.sql import SparkSession
spark = SparkSession.builder.getOrCreate()
```

6. Start running Spark code in the Jupyter notebook environment!
