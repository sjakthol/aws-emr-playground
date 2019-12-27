include ../../utils/common.mk

NAME := $(notdir $(patsubst %/,%,$(dir $(abspath $(firstword $(MAKEFILE_LIST))))))
ECR_REPOSITORY = $(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com/$(DEPLOYMENT_NAME)/$(NAME)

login:
	$(AWS_CMD) ecr get-login --no-include-email | bash

build:
	docker build --pull -t $(NAME) .

push: build login
	docker tag $(NAME):latest $(ECR_REPOSITORY):latest
	docker push $(ECR_REPOSITORY):latest
