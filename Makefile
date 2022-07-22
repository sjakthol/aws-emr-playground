include ./utils/common.mk

define stack_template =

deploy-$(basename $(notdir $(1))): $(1)
	$(AWS_CMD) cloudformation deploy \
		--stack-name $(DEPLOYMENT_NAME)-$(basename $(notdir $(1)))$(STACK_NAME_SUFFIX) \
		--tags $(TAGS) \
		--parameter-overrides DeploymentName=$(DEPLOYMENT_NAME) $(EXTRA_PARAMS) \
		--no-fail-on-empty-changeset \
		--template-file $(1) \
		--capabilities CAPABILITY_NAMED_IAM

delete-$(basename $(notdir $(1))): $(1)
	$(AWS_CMD) cloudformation delete-stack \
		--stack-name $(DEPLOYMENT_NAME)-$(basename $(notdir $(1)))$(STACK_NAME_SUFFIX)

endef

$(foreach template, $(wildcard stacks/*.yaml), $(eval $(call stack_template,$(template))))

deploy-cluster-emr-5.36.0 delete-cluster-emr-5.36.0:
deploy-cluster-emr-6.7.0 delete-cluster-emr-6.7.0:
deploy-cluster-emr-%:
	$(MAKE) deploy-cluster EXTRA_PARAMS=ReleaseLabel=emr-$* STACK_NAME_SUFFIX=$(subst .,,$*)
delete-cluster-emr-%:
	$(MAKE) delete-cluster STACK_NAME_SUFFIX=$(subst .,,$*)

deploy-cluster: pre-deploy-cluster
pre-deploy-cluster:
	$(AWS_CMD) s3 sync scripts/ s3://$(DEPLOYMENT_NAME)-infra-emr-bootstrap/