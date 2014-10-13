# Google compute engine coreos environment

This represents a set of utilities for controlling a CoreOS cluster
running on Google compute engine. See "Intented workflow".

## Overview

The general idea of the system is that multiple clusters can exist,
but there is only one compute engine project. For most intends and
purposes only one cluster will probably be needed, but the

## Tools

For convenience a set of bash scripts exists to provide a small
wrapper around standard tools. Convenience in this regard is mostly
on account of authentication and not having to install these client
libraries. 


## Core concepts

The core of the system is of course the actual hosting of and routing
to services. The following sums up how this is handled.

### Service discovery

Service discovery within the cluster is handled though a combination
of projects:

- [etcd](https://github.com/coreos/etcd)
- [confd](https://github.com/kelseyhightower/confd)
- [HAProxy](http://www.haproxy.org/)

All of the above play a central role in the setup, their respective
project pages serves as a good source of information if one is looking
to dive deeper. The following sums up their purpose well enough for
continuing here:

#### etcd

Core element of a CoreOS cluster. Provides a distributed key value
and takes care of consensus disputes. Is in this project used to hold
ip:port endpoints for services

#### confd

Created by coreos contributors, polls etcd (or Consul) and updates
files based on golang templates. For our purposes it listens for new
services being registered in etcd and updates the haproxy
configuration file.

#### HAProxy

HAProxy is high performance load balancer. It is created by a linux
core contributor and is used by high traffic sites, such as reddit.
It's overall great and simple to configure

Services become discoverable by appearing in the etcd cluster, being
noticed by confd and gets written to the HAProxy config. The discovery
itself can happen on every server in the cluster, as they each run
a haproxy and confd process, that listens to the same etcd cluster.
This is all wrapped up in a [docker
container](https://registry.hub.docker.com/u/cstpdk/haproxy-confd/).

Because all servers in the cluster holds all the information, all the
servers have to do is register themselves to be discovered. The
public facing part of all this is Google compute engine load balancer.
This allows for easy DNS handling, and total ephemeral behaviour of
cluster nodes as each one can be removed at will.

How the requests can be matched depends on whether they are HTTP or
TCP requests.

#### HTTP services

Are easy to work with because HTTP headers gives a lot of nice
information. This mean that we can match on url host and path. So, we
can match requests on port 80 and route according to the information
within the request.

#### TCP services

Are a bit more cumbersome due to the absence of headers. This means
that we actually only have ports to determine where a requests must
go, and, assuming that more than one service is desirable we need to
open more

Starting from the top, a service is discoverable when an entry in etcd
like the following exists and holds necessary sub directories:

- /services/{{servicename}}

The necessary subdirectories are:

- /services/{{servicename}}/scheme
	- Either tcp or http
- /services/{{servicename}}/hosts/[0..n]
	- where each 0..n holds an entry of ip:port
- /services/{{servicename}}/host_port
	- This is **optional**, but very useful for tcp services. If
	set, the service will be resolvable on some.domain:host_port

It will then be matched by incoming requests on
*{{servicename}}.some.domain* and *some.domain/{{servicename}}*,
regardless of the domain. 

#### Local discovery

A subtle problem in the grand scheme of service discovery is how
services can discover their host. This is a prerequisite for doing
internal service discovery without going over the public internet. The
first obstacle in this is that everything runs in docker containers,
meaning that localhost is probably not the localhost you're looking
for. Circumventing the localhost issue is easily done with the docker
daemon itself, by using the bridge ip flag (--bip), we can ensure that
docker containers can always reach the host on the same ip.

> ExecStart=/usr/bin/docker -d --bip=172.17.42.1/16 -s=btrfs -r=false -H fd:// --dns 172.17.42.1 --dns 8.8.8.8

This only gets us half the way, because this only gets us to the
HAProxy, but requires us to use url path to hit actual services. This
is not possible when for instance pulling from the docker index where
url path can be prepended. So, what we want is a DNS solution. As is
hinted above with the docker -d command, we can see that we also use
the docker host as dns service. This means that we resolve requests
through here before looking to the public internet (courtesy of Google
DNS in this case). In order for this local resolving to be meaning we
have to do some actual resolving on the host, this is handled with
[dnsmasq](http://www.thekelleys.org.uk/dnsmasq/doc.html), again in
a [container](https://registry.hub.docker.com/u/cstpdk/dnsmasq/),
resolving all requests to .local to the host address. This means that
some registered service, eg. service1, will be resolvable as
service1.local and point to the same service as
service1.some.public.domain.


## Provisioning

Provisioning is two-fold, between new servers and new service
instances. 

### Servers

The ./servers folder holds scripts to create, destroy and listing
servers. These are all wrappers around gcloud commands, which can be
quite lengthy. The real benefit is in the creation of servers, as they
provide a reproducible way to instantiate certain types of servers,
such as coreos nodes and database servers.

### Services

Services are provisioned through CoreOS' fleet. See "intended workflow" for
how to write service files.

## Intented workflow

### Service definitions

Providing a service

### Update process

Updating services takes on 

### Persistent services

CoreOS handles serving certain types of services really well. It does
not, however, provide a good way to handle persistent data. This makes
it unsuitable to host for instance a database on. The trouble comes
from the inherent distributed nature of CoreOS making it unnatural to
tie services to servers. For this reason, persistent data services
should be kept on a servers outside of CoreOS clusters.

### Files

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

## Ongoing pain points

- TCP Routing is really not very graceful, due to the port requirement
described above.

- Update process is a kinda-fragile bash script
