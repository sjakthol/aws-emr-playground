#!/bin/bash

# Helper script to connect to various Web UIs on the EMR cluster master node.

set -euo pipefail

INSTANCE_ID="${1:-Pass instance ID as the first parameter}"
INSTANCE_IP=$(aws ec2 describe-instances --instance-ids i-008eca32796200506 --query Reservations[0].Instances[0].PrivateIpAddress --output text)

echo "Updating SSM agent on instance $INSTANCE_ID with IP $INSTANCE_IP"
SSM_CMD_ID=$(aws ssm send-command --instance-ids $INSTANCE_ID --document-name AWS-UpdateSSMAgent --query Command.CommandId --output text)

while [ $(aws ssm list-command-invocations \
    --command-id $SSM_CMD_ID \
    --details \
    --query CommandInvocations[0].Status \
    --output text) == InProgress ]; do
    echo "SSM Agent update still in progress..."
    sleep 2
done

echo "Starting forwarding for JupyterLab: http://localhost:8888"
aws ssm start-session --target $INSTANCE_ID --document-name AWS-StartPortForwardingSession --parameters '{"portNumber":["8888"],"localPortNumber":["8888"]}' >/dev/null &

echo "Starting forwarding for Zeppelin: http://localhost:8890"
aws ssm start-session --target $INSTANCE_ID --document-name AWS-StartPortForwardingSession --parameters '{"portNumber":["8890"],"localPortNumber":["8890"]}' >/dev/null &

echo "Starting forwarding for Yarn Resource Manager: http://localhost:8088"
aws ssm start-session --target $INSTANCE_ID --document-name AWS-StartPortForwardingSessionToRemoteHost --parameters '{"host":["'$INSTANCE_IP'"],"portNumber":["8088"],"localPortNumber":["8088"]}' >/dev/null  &

echo "Starting forwarding for Ganglia: http://localhost:8080/ganglia/"
aws ssm start-session --target $INSTANCE_ID --document-name AWS-StartPortForwardingSession --parameters '{"portNumber":["80"],"localPortNumber":["8080"]}' >/dev/null  &

echo "Starting forwarding for Yarn Application Proxy: http://localhost:20888/proxy/<yarn_application_id>/"
aws ssm start-session --target $INSTANCE_ID --document-name AWS-StartPortForwardingSessionToRemoteHost --parameters '{"host":["'$INSTANCE_IP'"],"portNumber":["20888"],"localPortNumber":["20888"]}' >/dev/null  &

wait