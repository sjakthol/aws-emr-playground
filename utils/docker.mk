include ../../utils/common.mk

TAG ?= latest
ECR_REPOSITORY = $(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com/$(DEPLOYMENT_NAME)/$(NAME)

ifndef NAME
	$(error NAME variable must be defined!)
endif

build:
	docker build --pull -t $(NAME):$(TAG) $(BUILD_EXTRA_ARGS) .

push: build
	docker tag $(NAME):$(TAG) $(ECR_REPOSITORY):$(TAG)
	docker push $(ECR_REPOSITORY):$(TAG)
