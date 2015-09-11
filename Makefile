.PHONY: all default build

DOCKER_IMAGE_NAME := wyuelin/mkdocs

default: build 

build:
	docker build -t "$(DOCKER_IMAGE_NAME)" .
