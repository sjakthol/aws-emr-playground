CloudFormation templates for setting up Amazon EMR clusters.

## Features

* Infra layer with IAM roles, S3 buckets and security groups
* EMR cluster with JupyterLab & Zeppelin notebook environments
* Step Functions state machines for running EMR workflows

## Prerequisites

You'll need the VPC and bucket stacks from [sjakthol/aws-account-infra](https://github.com/sjakthol/aws-account-infra).

## Deployment

### Infra

Deploy infra (buckets, roles, policies, security groups etc.):

```
make deploy-infra-emr
make deploy-infra-workflow
```

### Clusters

Deploy EMR clusters:

```bash
# Default cluster
make deploy-cluster

# Specific EMR version (supports EMR versions that use Amazon Linux 2)
make deploy-cluster-emr-5.33.1
make deploy-cluster-emr-6.4.0
make deploy-cluster-emr-x.x.x
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

### Workflows

Deploy workflows:

```
make deploy-workflow-static
make deploy-workflow-parametrized
```

Workflows include:

* static workflow that hard-codes cluster configuration and defines steps in state machine definition
* parametrized workflow that takes cluster configuration and steps from execution input (see CloudFormation template for example)

### Cleanup

Delete clusters:

```bash
# Default cluster
make delete-cluster

# Cluster created with specific EMR version
make delete-cluster-emr-5.33.1
make delete-cluster-emr-6.4.0
make delete-cluster-emr-x.x.x
```

Delete workflows:

```
make delete-workflow-parametrized
make delete-workflow-static
```

Delete infra (must empty S3 buckets and clean EMR managed security group rules manually)

```
make delete-infra-workflow
make delete-infra-emr
```

## Credits
* JupyterLab setup: https://aws.amazon.com/blogs/big-data/running-jupyter-notebook-and-jupyterhub-on-amazon-emr/

## License

MIT
