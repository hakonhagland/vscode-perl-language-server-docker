ROOT := $(shell pwd)

.PHONY: build run run-vscode

USERNAME := dockeruser
TAG_NAME := ubuntu-vscode-perl

build:
	@echo "Building Docker image..."
	@docker build --build-arg HOST_UID=$(shell id -u) \
	              --build-arg HOST_GID=$(shell id -g) \
	              --build-arg USERNAME=$(USERNAME) \
	              -t $(TAG_NAME) .

run:
	@echo "Running Docker container..."
	@mkdir -p $(ROOT)/share
	@if command -v xhost >/dev/null 2>&1; then \
		xhost +local:docker; \
		docker run --user $(shell id -u):$(shell id -g) \
	            -v $(ROOT)/share:/home/$(USERNAME)/share \
		        -v /tmp/.X11-unix:/tmp/.X11-unix \
		        -e DISPLAY=$(DISPLAY) \
	            -it --rm $(TAG_NAME); \
		xhost -local:docker; \
	else \
		echo "xhost command not found. Please ensure X11 is set up correctly."; \
		exit 1; \
	fi

# NOTE: Running VSCode in Docker container requires X11 server to be running on host machine.
#       If you are using Windows, you can use Xming or VcXsrv.
# 	    If you are using macOS, you can use XQuartz.
# NOTE: When running VS Code in a container, we need to disable the sandbox
#       by passing the "--no-sandbox" flag.
# TODO: For some reason, the "--verbose" flag is also needed to run VSCode in the container.
#       This is a temporary workaround until a better solution is found.
run-vscode:
	@echo "Running Docker container with VSCode..."
	@if command -v xhost >/dev/null 2>&1; then \
	    mkdir -p $(ROOT)/share; \
		xhost +local:docker ; \
		docker run --user $(shell id -u):$(shell id -g) \
		           -v $(ROOT)/share:/home/$(USERNAME)/share \
		           -v /tmp/.X11-unix:/tmp/.X11-unix \
		           -e DISPLAY=$(DISPLAY) \
		           -it --rm $(TAG_NAME) code --verbose --no-sandbox /home/$(USERNAME)/share > /dev/null 2>&1; \
		xhost -local:docker; \
	else \
		echo "xhost command not found. Please ensure X11 is set up correctly."; \
		exit 1; \
	fi
