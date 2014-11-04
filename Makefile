.PHONY: cloud-config.yaml .entry-node images

# Local variables
makefile := $(abspath $(lastword $(MAKEFILE_LIST)))

dir := $(shell dirname $(makefile))

include $(dir)/variables.sh

default: images

images:
	docker build -t $(GCLOUD_PROJECT)-fleet $(dir)/images/fleet

start-vagrant: cloud-config.yaml
	-vagrant destroy -f
	$(MAKE) cloud-config.yaml
	vagrant up

update-discovery-token:
	sed -i.bak -r 's|discovery:(.*$$)|discovery: '$(COREOS_TOKEN)'|' cloud-config.yaml

update-gcloud-project:
	sed -i.bak -r 's|GCLOUD_PROJECT=(.*$$)|GCLOUD_PROJECT='"$(GCLOUD_PROJECT)"'|' cloud-config.yaml

cloud-config.yaml: update-discovery-token update-gcloud-project
	rm cloud-config.yaml.bak # Yeah. Your backup doesn't interest me beyond mac compatibility

scripts/run_jenkins.sh:
	sed -i.bak -r 's|GCS_BUCKET=(.*$$)|GCS_BUCKET='"$(GCS_BUCKET)"'|' $@

.entry-node:
	./servers/list | grep -E "core[0-9]+" | awk '{print $$5}' | head -1 > $@

README.pdf: README.md
	pandoc -o README.pdf README.md
