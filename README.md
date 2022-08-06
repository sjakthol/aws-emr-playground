CloudFormation templates for setting up Amazon EMR clusters.

## Features

* Infra layer with IAM roles, S3 buckets and security groups
* EMR cluster with JupyterLab & Zeppelin notebook environments

## Prerequisites

You'll need the VPC and bucket stacks from [sjakthol/aws-account-infra](https://github.com/sjakthol/aws-account-infra).

## Deployment

### Infra

Deploy infra (buckets, roles, policies, security groups etc.):

```
make deploy-infra-emr
```

### Clusters

Deploy EMR clusters:

```bash
# Default cluster
make deploy-cluster

# Specific EMR version (supports EMR versions that use Amazon Linux 2)
make deploy-cluster-emr-5.36.0
make deploy-cluster-emr-6.7.0
make deploy-cluster-emr-x.x.x
```

When the cluster is ready, use Amazon SSM Session Manager to access services running on the cluster (requires [SSM Session Manager Plugin for AWS CLI](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html)). Execute
```bash
./scripts/setup-port-forwarding.sh <master_instance_id>
```
where `<master_instance_id>` is the ID of the EMR cluster master node to establish a connection to the following services

* JupyterLab: http://localhost:8888
* Ganglia: http://localhost:8080/ganglia/
* Yarn Resource Manager: http://localhost:8088
* Yarn Application Manager UI Proxy (e.g. Spark UI): http://localhost:20888/proxy/__YARN_APPLICATION_ID_HERE__/
* Zeppelin: http://localhost:8890

### Cleanup

Delete clusters:

```bash
# Default cluster
make delete-cluster

# Cluster created with specific EMR version
make delete-cluster-emr-5.36.0
make delete-cluster-emr-6.7.0
make delete-cluster-emr-x.x.x
```

Delete infra (must empty S3 buckets and clean EMR managed security group rules manually)

```
make delete-infra-emr
```

## Credits
* JupyterLab setup: https://aws.amazon.com/blogs/big-data/running-jupyter-notebook-and-jupyterhub-on-amazon-emr/

## See Also

* Step Function ETLs - Orchestrate EMR workflows with AWS Step Functions: https://github.com/sjakthol/aws-step-function-etls

## License

MIT
