## Spark in Docker

EMR 6.x allows Spark applications to be executed inside Docker container. Use the following
commands to build a runtime image for PySpark scripts:

```bash
cd containers/pyspark-runtime/ && make build push
```


### Running PySpark Applications

SSH into master node and run the following commands to execute a PySpark script (`main.py`) inside
the pyspark-runtime container:
```bash
ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
DOCKER_IMAGE_NAME=$ACCOUNT.dkr.ecr.eu-north-1.amazonaws.com/en1-emr-default/pyspark-runtime:base
spark-submit --master yarn \
    --deploy-mode cluster \
    --conf spark.executorEnv.YARN_CONTAINER_RUNTIME_TYPE=docker \
    --conf spark.executorEnv.YARN_CONTAINER_RUNTIME_DOCKER_IMAGE=$DOCKER_IMAGE_NAME \
    --conf spark.yarn.appMasterEnv.YARN_CONTAINER_RUNTIME_TYPE=docker \
    --conf spark.yarn.appMasterEnv.YARN_CONTAINER_RUNTIME_DOCKER_IMAGE=$DOCKER_IMAGE_NAME \
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

### Packaging Python Dependencies to a Zipfile

You can also package Python dependencies to a zipfile and provide the dependencies to
your application at runtime. Create the zipfile as follows:

```
rm -fr libs libs.zip && mkdir libs
python3 -m pip install -t libs/ boto3 numpy pyarrow
(cd libs && zip -qr ../libs.zip *)
```

You can make PySpark use Python dependencies from that zipfile as follows

```
ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
DOCKER_IMAGE_NAME=$ACCOUNT.dkr.ecr.eu-north-1.amazonaws.com/en1-emr-default/pyspark-runtime:base
spark-submit --master yarn --deploy-mode cluster \
    --conf spark.executorEnv.YARN_CONTAINER_RUNTIME_TYPE=docker \
    --conf spark.executorEnv.YARN_CONTAINER_RUNTIME_DOCKER_IMAGE=$DOCKER_IMAGE_NAME \
    --conf spark.executorEnv.PYTHONPATH=libs.zip/ \
    --conf spark.yarn.appMasterEnv.YARN_CONTAINER_RUNTIME_TYPE=docker \
    --conf spark.yarn.appMasterEnv.YARN_CONTAINER_RUNTIME_DOCKER_IMAGE=$DOCKER_IMAGE_NAME \
    --conf spark.yarn.appMasterEnv.PYTHONPATH=libs.zip/ \
    --archives libs.zip \
    main.py -v
```