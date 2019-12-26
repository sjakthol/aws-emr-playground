CloudFormation templates for setting up Amazon EMR clusters.

## Features

* Infra layer with IAM roles, S3 buckets and security groups
* EMR cluster with JupyterLab & Zeppelin notebook environments

## Prerequisites

You'll  need to setup the VPC, subnet and bucket stacks from [sjakthol/aws-account-infra](https://github.com/sjakthol/aws-account-infra).

## Deployment

Create the EMR infra (roles, buckets, security groups) by running

```
make deploy-infra
```

Once done, you deploy a cluster by running
```
make deploy-cluster
```

When the cluster has started up, create an SSH tunnel to the master node to access Zeppelin / JupyterLab:
```
ssh -L localhost:8888:localhost:8888 -L localhost:8890:localhost:8890 hadoop@<master_instance_id>
```

where `<master_instance_id>` is the ID of the master node (requires [SSM Session Manager Plugin for AWS CLI](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html) and [SSH configuration](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-getting-started-enable-ssh-connections.html) to transfer SSH connection data through SSM).

Alternatively, you can modify the master instance security group to allow incoming connections to port 22 from your IP address and SSH to the master using a public IP address.

Once done, you can access services as follows:
* JupyterLab - http://localhost:8888/
* Zeppelin - http://localhost:8890/

## Credits
* JupyterLab setup: https://aws.amazon.com/blogs/big-data/running-jupyter-notebook-and-jupyterhub-on-amazon-emr/

## License

MIT
