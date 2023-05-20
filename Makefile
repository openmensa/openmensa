#!/usr/bin/env make -f

IMAGE_NAME=ghcr.io/openmensa/openmensa:main

image:
	docker build . --tag ${IMAGE_NAME}
