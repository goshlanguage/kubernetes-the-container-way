# Kubernetes the container way

This guide is inspired by Kelsey Hightower's [Kubernetes the hard way](https://github.com/kelseyhightower/kubernetes-the-hard-way).

It includes a docker-compose file and a Makefile to aide in quickly getting up and running so you can get familiar with etcd, and the 5 services that make kubernetes work.

These core services are:

- apiserver
- controller
- proxy
- scheduler
- kubelet

All of their respective binaries are packaged in a docker container from google called `hyperkube`, which can be found here:
https://console.cloud.google.com/gcr/images/google-containers/US/hyperkube?gcrImageListsize=30

or via it's registry:

```
docker run gcr.io/google-containers/hyperkube:v1.12.2 ls /usr/local/bin/
kube-apiserver
kube-controller-manager
kube-proxy
kube-scheduler
kubelet
kubectl
```

We can bring up etcd, and the kubernetes api server by running:

```
make up
```

This invokes docker-compose up -d after generating certificates. You can confirm your apiserver and etcd are up by making a request to your local apiserver:

```
curl http://localhost:8080/version
{
  "major": "1",
  "minor": "12",
  "gitVersion": "v1.12.2",
  "gitCommit": "17c77c7898218073f14c8d573582e8d2313dc740",
  "gitTreeState": "clean",
  "buildDate": "2018-10-24T06:43:59Z",
  "goVersion": "go1.10.4",
  "compiler": "gc",
  "platform": "linux/amd64"
}%
```

# Debugging

Didn't get a response from the apiserver? You can get log output from the apiserver with:

```

```

TODO:

[] Setup etcd cluster w/ TLS
[] Configure Kubernetes apiserver to use TLS for etcd

# ETCD

etcd starts up with [bin/etcd_entry.sh](bin/etcd_entry.sh).

To test the health of your cluster, run:

```
docker-compose exec etcd etcdctl member list
1dc00bcbf8c1a1fc: name=etcd peerURLs=http://192.168.112.2:2380 clientURLs=http://192.168.112.2:2379 isLeader=true
```

Currently, we only have 1 etcd node. Ideally, we'd have no less than 3, but this does allow us to explore the data stored in etcd. _NOTE_: We set `ETCDCTL_API=3` in [docker-compose.yml](docker-compose.yml) so that etcdctl uses the version 3 etcd api. You can see a list of available functions with the help flag:

```
docker-compose exec etcd etcdctl -h
[truncated]

COMMANDS:
	get			Gets the key or a range of keys
	put			Puts the given key into the store
	del			Removes the specified key or range of keys [key, range_end)
	txn			Txn processes all the requests in one transaction
	compaction		Compacts the event history in etcd
	alarm disarm		Disarms all alarms
	alarm list		Lists all alarms
	defrag			Defragments the storage of the etcd members with given endpoints
	endpoint health		Checks the healthiness of endpoints specified in `--endpoints` flag
	endpoint status		Prints out the status of endpoints specified in `--endpoints` flag
	endpoint hashkv		Prints the KV history hash for each endpoint in --endpoints
	move-leader		Transfers leadership to another etcd cluster member.
	watch			Watches events stream on keys or prefixes
	version			Prints the version of etcdctl
	lease grant		Creates leases
	lease revoke		Revokes leases
	lease timetolive	Get lease information
	lease list		List all active leases
	lease keep-alive	Keeps leases alive (renew)
	member add		Adds a member into the cluster
	member remove		Removes a member from the cluster
	member update		Updates a member in the cluster
	member list		Lists all members in the cluster
	snapshot save		Stores an etcd node backend snapshot to a given file
	snapshot restore	Restores an etcd member snapshot to an etcd directory
	snapshot status		Gets backend snapshot status of a given file
	make-mirror		Makes a mirror at the destination etcd cluster
	migrate			Migrates keys in a v2 store to a mvcc store
	lock			Acquires a named lock
	elect			Observes and participates in leader election
	auth enable		Enables authentication
	auth disable		Disables authentication
	user add		Adds a new user
	user delete		Deletes a user
	user get		Gets detailed information of a user
	user list		Lists all users
	user passwd		Changes password of user
	user grant-role		Grants a role to a user
	user revoke-role	Revokes a role from a user
	role add		Adds a new role
	role delete		Deletes a role
	role get		Gets detailed information of a role
	role list		Lists all roles
	role grant-permission	Grants a key to a role
	role revoke-permission	Revokes a key from a role
	check perf		Check the performance of the etcd cluster
	help			Help about any command

    [truncated]
```

To see a comprehensive guide for interacting with etcd, see: [CoreOS - Interacting with etcd](https://coreos.com/etcd/docs/latest/dev-guide/interacting_v3.html).

First, let's list the keys we have available:

```
docker-compose exec etcd etcdctl get / --prefix --keys-only
/registry/apiregistration.k8s.io/apiservices/v1.
/registry/apiregistration.k8s.io/apiservices/v1.apps
/registry/apiregistration.k8s.io/apiservices/v1.authentication.k8s.io
/registry/apiregistration.k8s.io/apiservices/v1.authorization.k8s.io
/registry/apiregistration.k8s.io/apiservices/v1.autoscaling
/registry/apiregistration.k8s.io/apiservices/v1.batch
/registry/apiregistration.k8s.io/apiservices/v1.networking.k8s.io
/registry/apiregistration.k8s.io/apiservices/v1.rbac.authorization.k8s.io
[truncated]
```

We can get more information about any key we want to inspect with `etcdctl get`. In this example, let's take a look at the data kubernetes stores for the network:

```
docker-compose exec etcd etcdctl get /registry/apiregistration.k8s.io/apiservices/v1.networking.k8s.io

/registry/apiregistration.k8s.io/apiservices/v1.networking.k8s.io
{
    "kind":"APIService","apiVersion":"apiregistration.k8s.io/v1beta1","metadata":{"name":"v1.networking.k8s.io","uid":"ee4a33f3-dd7c-11e8-b652-0242c0a88003","creationTimestamp":"2018-11-01T02:22:07Z","labels":{"kube-aggregator.kubernetes.io/automanaged":"onstart"}},"spec":{"service":null,"group":"networking.k8s.io","version":"v1","groupPriorityMinimum":17200,"versionPriority":15},"status":{"conditions":[{"type":"Available","status":"True","lastTransitionTime":"2018-11-01T02:22:07Z","reason":"Local","message":"Local APIServices are always available"}]}
}
```

I've pretty printed this for better legibility by running:
```
docker-compose exec etcd etcdctl get /registry/apiregistration.k8s.io/apiservices/v1.networking.k8s.io | grep -v "/registry/apiregistration.k8s.io/apiservices/v1.networking.k8s.io" > tmp; jq . tmp; rm -f tmp

{
  "kind": "APIService",
  "apiVersion": "apiregistration.k8s.io/v1beta1",
  "metadata": {
    "name": "v1.networking.k8s.io",
    "uid": "ee4a33f3-dd7c-11e8-b652-0242c0a88003",
    "creationTimestamp": "2018-11-01T02:22:07Z",
    "labels": {
      "kube-aggregator.kubernetes.io/automanaged": "onstart"
    }
  },
  "spec": {
    "service": null,
    "group": "networking.k8s.io",
    "version": "v1",
    "groupPriorityMinimum": 17200,
    "versionPriority": 15
  },
  "status": {
    "conditions": [
      {
        "type": "Available",
        "status": "True",
        "lastTransitionTime": "2018-11-01T02:22:07Z",
        "reason": "Local",
        "message": "Local APIServices are always available"
      }
    ]
  }
}
```

If you're familiar with writing kubernetes manifests, this should look very familiar to you.

https://kubernetes.io/docs/tasks/administer-cluster/configure-upgrade-etcd/
