KUBE_VM ?= virtualbox
KUBE_CPU ?= 2
KUBE_MEM ?= 8192

.PHONY: help start clean new-client new-server start-all start-ingress \
  start-infra start-vaults start-services print-hosts minikube
.DEFAULT_GOAL := help

help: ## Print this message and exit.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%20s\033[0m : %s\n", $$1, $$2}' $(MAKEFILE_LIST)

minikube: cmd-minikube ## Start minikube
	@sudo minikube ip 2>/dev/null || sudo minikube start --vm-driver $(KUBE_VM) --cpus $(KUBE_CPU) --memory $(KUBE_MEM)

start:  ## Start all OTA+ services.
	@scripts/start.sh start-all

clean: cmd-minikube ## Delete minikube and all service data.
	@sudo minikube delete >/dev/null || true
	@rm -rf generated/

new-client: %: start_%       ## Create a new client with a given name.
new-server: %: start_%       ## Create a new set of server credentials.
start-all: %: start_%        ## Start all infra and OTA+ services.
start-ingress: %: start_%    ## Install Nginx Ingress Controller
start-infra: %: start_%      ## Create infrastructure configs and apply to the cluster.
start-vaults: %: start_%     ## Start all vault instances.
start-services: %: start_%   ## Start the OTA+ services.
print-hosts: %: start_%      ## Print the service mappings for /etc/hosts
templates: %: start_%        ## Generate all the k8s files

start_%: # Pass the target as an argument to start.sh
	@scripts/start.sh $*

cmd-%: # Check that a command exists.
	@: $(if $$(command -v ${*} 2>/dev/null),,$(error Please install "${*}" first))
