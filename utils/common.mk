# Mapping from long region names to shorter ones that is to be
# used in the stack names
AWS_eu-west-1_PREFIX = ew1
AWS_us-east-1_PREFIX = ue1
AWS_eu-north-1_PREFIX = en1

# Some defaults
AWS ?= aws
AWS_REGION ?= eu-north-1

AWS_CMD := $(AWS) --region $(AWS_REGION)
AWS_ACCOUNT_ID = $(eval AWS_ACCOUNT_ID := $(shell $(AWS_CMD) sts get-caller-identity --query Account --output text))$(AWS_ACCOUNT_ID)

# Name of the cluster stack to operate on (change to support multiple deployments)
CLUSTER_STACK_NAME ?= default

STACK_REGION_PREFIX := $(AWS_$(AWS_REGION)_PREFIX)
DEPLOYMENT_NAME := $(STACK_REGION_PREFIX)-emr-$(CLUSTER_STACK_NAME)
TAGS ?= DeploymentName=$(DEPLOYMENT_NAME) DeploymentGroup=$(STACK_REGION_PREFIX)-emr
