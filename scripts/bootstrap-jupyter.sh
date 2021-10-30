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
sudo mkdir -p /var/log/jupyter/

# Create Jupyter config
cat > /home/hadoop/.jupyter/jupyter_notebook_config.py << EOF
from s3contents import S3ContentsManager

c = get_config()

c.NotebookApp.contents_manager_class = S3ContentsManager
c.S3ContentsManager.bucket = "${DEPLOYMENT_NAME}-infra-notebooks"
c.S3ContentsManager.prefix = "jupyter"
EOF

# Create Jupyter unit (Amazon Linux 2 with Systemd)
cat << EOF | sudo tee /usr/local/bin/pyspark-jupyter
#!/bin/bash
export PYSPARK_PYTHON="python3"
export PYSPARK_DRIVER_PYTHON="jupyter"
export PYSPARK_DRIVER_PYTHON_OPTS="lab --no-browser --log-level=INFO --ip 127.0.0.1 --LabApp.token=''"
pyspark
EOF

sudo chmod +x /usr/local/bin/pyspark-jupyter

cat << EOF | sudo tee /etc/systemd/system/pyspark-jupyter.service
[Unit]
Description=JupyterLab Service
After=network.target
StartLimitIntervalSec=0

[Service]
Type=simple
Restart=always
RestartSec=5
User=hadoop
WorkingDirectory=/home/hadoop
ExecStart=/usr/local/bin/pyspark-jupyter

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl start pyspark-jupyter
