PACKER_BINARY ?= packer
PACKER_VARIABLES := binary_bucket_name kubernetes_version kubernetes_build_date docker_version cni_version cni_plugin_version source_ami_id arch instance_type

arch ?= x86_64
ifeq ($(arch), arm64)
instance_type ?= a1.large
else
instance_type ?= m4.large
endif

AWS_DEFAULT_REGION ?= us-west-2

T_RED := \e[0;31m
T_GREEN := \e[0;32m
T_YELLOW := \e[0;33m
T_RESET := \e[0m

.PHONY: all
all: 1.12 1.13 1.14

.PHONY: validate
validate:
	$(PACKER_BINARY) validate $(foreach packerVar,$(PACKER_VARIABLES), $(if $($(packerVar)),--var $(packerVar)=$($(packerVar)),)) eks-worker-al2.json

.PHONY: k8s
k8s: validate
	@echo "$(T_GREEN)Building AMI for version $(T_YELLOW)$(kubernetes_version)$(T_GREEN) on $(T_YELLOW)$(arch)$(T_RESET)"
	$(PACKER_BINARY) build $(foreach packerVar,$(PACKER_VARIABLES), $(if $($(packerVar)),--var $(packerVar)=$($(packerVar)),)) eks-worker-al2.json

# Build dates and versions taken from https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html

.PHONY: 1.12
1.12:
	$(MAKE) k8s kubernetes_version=1.12.10 kubernetes_build_date=2020-01-22

.PHONY: 1.13
1.13:
	$(MAKE) k8s kubernetes_version=1.13.12 kubernetes_build_date=2020-01-22

.PHONY: 1.14
1.14:
	$(MAKE) k8s kubernetes_version=1.14.9 kubernetes_build_date=2020-01-22