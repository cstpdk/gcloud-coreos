.PHONY: cloud-config.yaml .entry-node

default:
	-vagrant destroy -f
	$(MAKE) cloud-config.yaml
	vagrant up

.entry-node:
	./servers/list | grep -E "core[0-9]+" | awk '{print $$6}' | head -1 > $@

cloud-config.yaml:
	sed -i.bak -r 's|discovery:(.*$$)|discovery: '`curl -s https://discovery.etcd.io/new`'|' cloud-config.yaml
	rm cloud-config.yaml.bak # Yeah. Your backup doesn't interest beyond being mac compatibility

.zone:
	echo "europe-west1-b" > .zone
