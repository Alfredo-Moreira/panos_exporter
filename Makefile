

GO           ?= go
GOFMT        ?= $(GO)fmt
FIRST_GOPATH := $(firstword $(subst :, ,$(shell $(GO) env GOPATH)))
pkgs          = ./...

BIN_DIR                 ?= $(shell pwd)/build
VERSION ?= $(shell cat VERSION)
REVERSION ?=$(shell git log -1 --pretty="%H")
BRANCH ?=$(shell git rev-parse --abbrev-ref HEAD)
TIME ?=$(shell date --rfc-3339=seconds)
HOST ?=$(shell hostname)  
DOCKER := $(shell { command -v podman || command -v docker; } 2>/dev/null)

all:  fmt style  build  docker-build rpm  docker-rpm


 
style:
	@echo ">> checking code style"
	! $(GOFMT) -d $$(find . -path ./vendor -prune -o -name '*.go' -print) | grep '^'

check_license:
	@echo ">> checking license header"
	@licRes=$$(for file in $$(find . -type f -iname '*.go' ! -path './vendor/*') ; do \
               awk 'NR<=3' $$file | grep -Eq "(Copyright|generated|GENERATED)" || echo $$file; \
       done); \
       if [ -n "$${licRes}" ]; then \
               echo "license header checking failed:"; echo "$${licRes}"; \
               exit 1; \
       fi

build: | 
	@echo ">> building binaries"
	CGO_ENABLED=0 $(GO) build -o build/panos_exporter -ldflags  '-X "main.Version=$(VERSION)" -X  "main.BuildRevision=$(REVERSION)" -X  "main.BuildBranch=$(BRANCH)" -X "main.BuildTime=$(TIME)" -X "main.BuildHost=$(HOSTNAME)"'

docker-build:
	@echo ">> building binaries in docker container"
	$(DOCKER) run -v `pwd`:/go/src/github.com/Alfredo-Moreira/panos_exporter  -w /go/src/github.com/Alfredo-Moreira/panos_exporter docker.io/Alfredo-Moreira/prom-builder  make build

rpm: | build
	@echo ">> build rpm package"
	$(RPM)

docker-rpm:
	@echo ">> build rpm package in docker container"
	$(DOCKER) run -v `pwd`:/go/src/github.com/Alfredo-Moreira/panos_exporter  -w /go/src/github.com/Alfredo-Moreira/panos_exporter docker.io/Alfredo-Moreira/prom-builder  make rpm



fmt:
	@echo ">> format code style"
	$(GOFMT) -w $$(find . -path ./vendor -prune -o -name '*.go' -print) 


clean:
	rm -rf $(BIN_DIR)

.PHONY: all style check_license  build  docker-build rpm docker-rpm fmt 
