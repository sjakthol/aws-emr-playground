CloudFormation templates for setting up Amazon EMR clusters.

## Features

* Infra layer with IAM roles, S3 buckets and security groups
* EMR cluster with JupyterLab & Zeppelin notebook environments

## Prerequisites

You'll need to setup the VPC, subnet and bucket stacks from [sjakthol/aws-account-infra](https://github.com/sjakthol/aws-account-infra).

## Deployment

Create the EMR infra (roles, buckets, security groups) by running

```
make deploy-infra
```

Then, deploy a cluster by running

```bash
# Default cluster
make deploy-cluster

# Specific EMR version (supports EMR versions that use Amazon Linux 2)
make deploy-cluster-5.33.1
make deploy-cluster-6.4.0
make deploy-cluster-x.x.x
```

When the cluster is ready, use SSM Port Forwarding to access Zeppelin / JupyterLab on the cluster master node:
```bash
# Zeppelin
aws ssm start-session --target <master_instance_id> --document-name AWS-StartPortForwardingSession --parameters '{"portNumber":["8890"],"localPortNumber":["8890"]}'

# JupyterLab
aws ssm start-session --target <master_instance_id> --document-name AWS-StartPortForwardingSession --parameters '{"portNumber":["8888"],"localPortNumber":["8888"]}'
```

where `<master_instance_id>` is the ID of the master node (requires [SSM Session Manager Plugin for AWS CLI](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html))

Once done, you can access services via the following URLs:
* JupyterLab - http://localhost:8888/
* Zeppelin - http://localhost:8890/

### Cleanup

Use the following commands to delete EMR clusters:

```bash
# Default cluster
make delete-cluster

# Cluster created with specific EMR version
make delete-cluster-5.33.1
make delete-cluster-6.4.0
make delete-cluster-x.x.x
```

Delete infra with (must empty S3 buckets manually)

```
make delete-infra
```

## Credits
* JupyterLab setup: https://aws.amazon.com/blogs/big-data/running-jupyter-notebook-and-jupyterhub-on-amazon-emr/

## License

MIT
