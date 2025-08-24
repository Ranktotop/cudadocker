.RECIPEPREFIX := >

VERSION ?= 11.8
FLAVOR ?= base

IMAGE_TAG := cudadocker:$(VERSION)-$(FLAVOR)
IMAGE_DIR := images/$(VERSION)/$(FLAVOR)

.PHONY: build test

build: $(IMAGE_DIR)/Dockerfile
>docker build -t $(IMAGE_TAG) $(IMAGE_DIR)

test: build
>docker run --rm -v $(PWD)/tests:/tests $(IMAGE_TAG) pytest /tests
