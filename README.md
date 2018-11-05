# Kubernetes the container way

This guide is inspired by Kelsey Hightower's [Kubernetes the hard way](https://github.com/kelseyhightower/kubernetes-the-hard-way).

It includes a docker-compose file and a Makefile to aide in quickly getting up and running so you can get familiar with etcd, and the 5 services that make kubernetes work. These 5 services can be broken into two primary components:

The Kubernetes Control Plane:
- etcd
- apiserver
- controller manager
- scheduler

Worker Node components:
- kubelet
- proxy

Together, these core services are:

- etcd
- apiserver
- controller
- scheduler
- kubelet
- proxy

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

We can bring up etcd, and the kubernetes apiserver by running:

```
make up
```

This invokes docker-compose up -d after generating certificates. You can confirm your apiserver and etcd are up by making a request to your local apiserver:

```
curl --cacert certs/ca.pem https://127.0.0.1:6443/
{
  "kind": "Status",
  "apiVersion": "v1",
  "metadata": {

  },
  "status": "Failure",
  "message": "forbidden: User \"system:anonymous\" cannot get path \"/\"",
  "reason": "Forbidden",
  "details": {

  },
  "code": 403
}
```

To learn more about the kubernetes apiserver, see: [The Kubernetes API](https://kubernetes.io/docs/concepts/overview/kubernetes-api/)

# Debugging

Didn't get a response from the apiserver? You can get log output from the apiserver with:

```
docker-compose logs kube-apiserver

kube-apiserver_1  | I1101 02:22:07.671775       1 cache.go:32] Waiting for caches to sync for autoregister controller
kube-apiserver_1  | I1101 02:22:07.672359       1 controller_utils.go:1027] Waiting for caches to sync for crd-autoregister controller
kube-apiserver_1  | W1101 02:22:07.760086       1 lease.go:226] Resetting endpoints for master service "kubernetes" to [192.168.128.3]
kube-apiserver_1  | I1101 02:22:07.773132       1 cache.go:39] Caches are synced for autoregister controller
kube-apiserver_1  | I1101 02:22:07.785344       1 cache.go:39] Caches are synced for AvailableConditionController controller
kube-apiserver_1  | I1101 02:22:07.785514       1 cache.go:39] Caches are synced for APIServiceRegistrationController controller
kube-apiserver_1  | I1101 02:22:07.786068       1 controller_utils.go:1034] Caches are synced for crd-autoregister controller
kube-apiserver_1  | I1101 02:22:08.674664       1 storage_scheduling.go:91] created PriorityClass system-node-critical with value 2000001000
kube-apiserver_1  | I1101 02:22:08.679688       1 storage_scheduling.go:91] created PriorityClass system-cluster-critical with value 2000000000
kube-apiserver_1  | I1101 02:22:08.679925       1 storage_scheduling.go:100] all system priority classes are created successfully or already exist.
```

Try `docker-compose logs etcd-0` to see more about what etcd is doing.

# etcd

etcd starts up with [bin/etcd_entrypoint.sh](bin/etcd_entrypoint.sh).

To test the health of your cluster, run:

```
docker-compose exec etcd etcdctl member list
1dc00bcbf8c1a1fc: name=etcd peerURLs=https://192.168.112.2:2380 clientURLs=https://192.168.112.2:2379 isLeader=true
```

Currently, we only have 1 etcd node. Ideally, we'd have no less than 3, but this does allow us to explore the data stored in etcd. _NOTE_: We set `ETCDCTL_API=3` in [docker-compose.yml](docker-compose.yml) so that etcdctl uses the version 3 etcd api. You can see a list of available functions with the help flag:

```
docker-compose exec etcd etcdctl -h
[TRUNCATED]

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

    [TRUNCATED]
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
[TRUNCATED]
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

# kube-controller-manager

If you've ever wondered how kubernetes services know what kind of load balancer to provision, let's take a look at the kube-controller-manager help text.

```
docker run --rm gcr.io/google-containers/hyperkube:v1.12.2 kube-controller-manager -h
[TRUNCATED]

Usage:
  kube-controller-manager [flags]

Generic flags:

      --allocate-node-cidrs                    Should CIDRs for Pods be allocated and set on the cloud provider.
      --cidr-allocator-type string             Type of CIDR allocator to use (default "RangeAllocator")
      --cloud-config string                    The path to the cloud provider configuration file. Empty string for no configuration file.
      --cloud-provider string                  The provider for cloud services. Empty string for no provider.
```

# Taking a Tour

Now that we have bits of the control plane up, let's take a tour of the API. To do this, we'll need to make sure our default service token exists, fetch this token, then compose our curl command to use our token:

```sh
kubectl get secret
NAME                  TYPE                                  DATA      AGE
default-token-rv6xh   kubernetes.io/service-account-token   3         19s

TOKEN=$(kubectl describe secret $(kubectl get secrets | grep default | cut -f1 -d ' ') | grep -E '^token' | cut -f2 -d':' | tr -d '\t')

curl https://127.0.0.1:6443/api/v1 --header "Authorization: Bearer $TOKEN" --insecure|head

  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  9438    0  9438    0     0   200k      0 --:--:-- --:--:-- --:--:--  204k
{
  "kind": "APIResourceList",
  "groupVersion": "v1",
  "resources": [
    {
      "name": "bindings",
      "singularName": "",
      "namespaced": true,
      "kind": "Binding",
      "verbs": [
```