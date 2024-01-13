# Override envars using -e
# make release -e NS=docker.io/juspay/test -e VERSION=1.2.3 -e IMAGE_NAME=docker-test
NS ?= juspaydotin
VERSION ?= v1.0.0
IMAGE_NAME ?= hyperswitch-control-center
BRANCH_NAME ?= $(shell git rev-parse --abbrev-ref HEAD)
CONTAINER_NAME ?= hyperswitch-control-center
CONTAINER_INSTANCE ?= default
SOURCE_COMMIT := $(shell git rev-parse HEAD)
RUN_TEST ?= false
.PHONY: build push shell run start stop rm release
build: Dockerfile
	$(info Building $(NS)/$(IMAGE_NAME):$(VERSION) / git-head: $(SOURCE_COMMIT))
	$(info git branch is $(BRANCH_NAME))
	# cp -R ~/.ssh .
	docker build --platform=linux/amd64 -t $(IMAGE_NAME):$(VERSION) -f Dockerfile --build-arg BRANCH_NAME="$(BRANCH_NAME)" --build-arg RUN_TEST="$(RUN_TEST)" .

push:
	docker tag $(IMAGE_NAME):$(VERSION) $(NS)/$(IMAGE_NAME):$(VERSION)
	docker push $(NS)/$(IMAGE_NAME):$(VERSION)

shell:
	docker run --rm --name $(CONTAINER_NAME)-$(CONTAINER_INSTANCE) -i -t $(PORTS) $(VOLUMES) $(ENV) $(NS)/$(IMAGE_NAME):$(VERSION) /bin/sh

run:
	docker run --rm --name $(CONTAINER_NAME)-$(CONTAINER_INSTANCE) $(PORTS) $(VOLUMES) $(ENV) $(NS)/$(IMAGE_NAME):$(VERSION)

start:
	docker run -d --name $(CONTAINER_NAME)-$(CONTAINER_INSTANCE) $(PORTS) $(VOLUMES) $(ENV) $(NS)/$(IMAGE_NAME):$(VERSION)

stop:
	docker stop $(CONTAINER_NAME)-$(CONTAINER_INSTANCE)

rm:
	docker rm $(CONTAINER_NAME)-$(CONTAINER_INSTANCE)
release: build
	make push -e VERSION=$(VERSION)
default: build