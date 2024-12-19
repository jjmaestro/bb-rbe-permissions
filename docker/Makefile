PROJECT_NAME := bb-rbe-permissions
REPO := $(abspath $(lastword $(MAKEFILE_LIST))/../..)

DOCKER := $(shell command -v docker || which docker)

ifndef DOCKER
$(error Can't find docker)
endif

DOCKERFILE := rbe_test
BASE_NAME := debian
TARGET ?= -rbe
DOCKER_TARGET := $(BASE_NAME)$(TARGET)
IMAGE_NAME := $(PROJECT_NAME)/$(DOCKER_TARGET)

REGISTRY := ghcr.io
GH_ORG := jjmaestro
GH_REPO_URL := https://github.com/$(GH_ORG)/$(PROJECT_NAME)
TAG := $(REGISTRY)/$(GH_ORG)/$(IMAGE_NAME):latest

ARCH ?= $(shell uname -m)
REPRODUCIBLE_CONTAINERS_VERSION ?= 0.1.4
USERNAME ?= buildbuddy


all:
	echo $(REPO)

.PHONY: all

run-image: gen-image
	$(DOCKER) run \
		--platform "linux/$(ARCH)" \
		--rm \
		--name "sandbox_$(PROJECT_NAME)_$(ARCH)" \
		--volume "$(REPO)":/src/workspace:rw \
		--tty \
		--interactive \
		--workdir /src/workspace \
		--entrypoint="/bin/bash" \
		$(IMAGE_NAME)

.PHONY: run-image

gen-image: .$(DOCKER_TARGET).Dockerfile

.PHONY: gen-image

.$(DOCKER_TARGET).Dockerfile: $(DOCKERFILE).Dockerfile
	$(DOCKER) build \
		--platform "linux/amd64,linux/arm64" \
		--file "$<" \
		--build-arg REPRODUCIBLE_CONTAINERS_VERSION="$(REPRODUCIBLE_CONTAINERS_VERSION)" \
		--build-arg USERNAME="$(USERNAME)" \
		--build-arg HOMEDIR="/$(USERNAME)" \
		--label org.opencontainers.image.source="$(GH_REPO_URL)" \
		--target "$(DOCKER_TARGET)" \
		--tag "$(IMAGE_NAME)" \
		. && \
	cp "$<" "$@"

push-image: gen-image
	$(DOCKER) image tag $(IMAGE_NAME) $(TAG) && \
	echo "\n\nEnter a GH Personal Access Token with (at least) write:packages scope:\n\n" && \
	$(DOCKER) login --username $(USER) $(REGISTRY)  && \
	$(DOCKER) push $(TAG)

.PHONY: push-image

pull-image:
	@echo "\n\nEnter a GH Personal Access Token with (at least) read:packages scope:\n\n" && \
	$(DOCKER) login --username $(USER) $(REGISTRY)  && \
	$(DOCKER) pull $(TAG)

.PHONY: pull-image
