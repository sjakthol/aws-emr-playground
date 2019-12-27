#!/bin/bash

set -euxo pipefail

DEPLOYMENT_NAME=${1:?DEPLOYMENT_NAME must be the first argument}

sudo yum install -y amazon-ssm-agent

if grep isMaster /mnt/var/lib/info/instance.json | grep true; then
  # Only relevant for workers.
  exit 0
fi

# TODO: Generate docker config with credentials to access ECR, make
# the config available to apps via HDFS and refresh the credentials
# periodically (cannot get ecr-creds helper working here)
#
# hadoop fs -put ~/.docker/config.json /user/hadoop/
