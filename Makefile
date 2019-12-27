include ./utils/common.mk

define stack_template =

deploy-$(basename $(notdir $(1))): $(1)
	$(AWS_CMD) cloudformation deploy \
		--stack-name $(DEPLOYMENT_NAME)-$(basename $(notdir $(1))) \
		--tags $(TAGS) \
		--parameter-overrides DeploymentName=$(DEPLOYMENT_NAME) \
		--template-file $(1) \
		--capabilities CAPABILITY_NAMED_IAM

delete-$(basename $(notdir $(1))): $(1)
	$(AWS_CMD) cloudformation delete-stack \
		--stack-name $(DEPLOYMENT_NAME)-$(basename $(notdir $(1)))

endef

$(foreach template, $(wildcard stacks/*.yaml), $(eval $(call stack_template,$(template))))


deploy-cluster: pre-deploy-cluster
pre-deploy-cluster:
	$(AWS_CMD) s3 sync scripts/ s3://$(DEPLOYMENT_NAME)-infra-bootstrap/