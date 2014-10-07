# Google compute engine coreos environment

"lowest" layer is Google Compute Engine (GCE), with CoreOS on top

- Makefile
	- Inits stuff
- Vagrantfile
	- Used to try out cluster locally
- cloud-config.yaml
	- This is the entire configuration of CoreOS. Google
	for tutorials. The project is called "cloud-init"
- fleetctl
	- This is used to interact with (systemd) service in CoreOS.
	https://coreos.com/docs/launching-containers/launching/fleet-using-the-client/
- gcloud
	- Used to interact with gcloud. On first run creates
	credentials for the other tools
- images
	- Holds some docker images used in deployment
- scp
	- Wrapper to scp stuff (note has severe room for improvement,
	currently only works for local -> remote)
- scripts
	- Scripts used mostly for initializing stuff on servers and in
	containers
- servers
	- holds scripts to destroy/create servers with different
	configs
- ssh
	- Wrapper to ssh into the cluster
- variables.sh
	- Variables specific to this project
- .entry-node
	- Node to enter into the cluster through
