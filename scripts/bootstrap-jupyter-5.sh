#!/bin/bash

set -euxo pipefail

if grep isMaster /mnt/var/lib/info/instance.json | grep false; then
  exit 0
fi

DEPLOYMENT_NAME=${1:?DEPLOYMENT_NAME must be the first argument}

# Install JupyterLab
sudo python3 -m pip install jupyterlab s3contents

# Prepare directories for Jupyter
mkdir -p /home/hadoop/.jupyter/
mkdir -p /var/log/jupyter/

# Create Jupyter config
cat > /home/hadoop/.jupyter/jupyter_notebook_config.py << EOF
from s3contents import S3ContentsManager

c = get_config()

c.NotebookApp.contents_manager_class = S3ContentsManager
c.S3ContentsManager.bucket = "${DEPLOYMENT_NAME}-infra-notebooks"
c.S3ContentsManager.prefix = "jupyter"
EOF

# Create Jupyter service (Amazon Linux 1 with Upstart)
cat << EOF | sudo tee /etc/init/jupyter.conf
respawn
post-stop exec sleep 5

start on runlevel [2345]
stop on runlevel [06]

script
sudo su - hadoop >> /var/log/jupyter/jupyter.log 2>&1 <<BASH_SCRIPT
  export PYSPARK_PYTHON="python3"
  export PYSPARK_DRIVER_PYTHON="jupyter"
  export PYSPARK_DRIVER_PYTHON_OPTS="lab --no-browser --log-level=INFO --ip 127.0.0.1 --LabApp.token=''"
  pyspark
BASH_SCRIPT
end script
EOF

# This might run before pyspark is installed. Start the process and ignore any
# errors. Upstart will respawn the process until pyspark is available.
sudo start jupyter || true
