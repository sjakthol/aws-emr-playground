include ../../utils/common.mk

TAG ?= latest
ECR_REPOSITORY = $(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com/$(DEPLOYMENT_NAME)/$(NAME)

ifndef NAME
	$(error NAME variable must be defined!)
endif

login:
	$(AWS_CMD) ecr get-login --no-include-email | bash

build:
	docker build --pull -t $(NAME):$(TAG) $(BUILD_EXTRA_ARGS) .

push: build login
	docker tag $(NAME):$(TAG) $(ECR_REPOSITORY):$(TAG)
	docker push $(ECR_REPOSITORY):$(TAG)
