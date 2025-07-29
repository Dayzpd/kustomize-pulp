# Pulp
Repo for managing the configuration of pulp across my homelab clusters.

## Pull Through Cache

I use cluster-api for provisioning Kubernetes clusters, and I often spin up/tear down clusters frequently when testing my bootstrapping process. This means I end up pulling images frequently which quickly becomes a problem when images come from rate limited registries like docker hub.

It follows that my primary use of Pulp is for pull through caches. It's a newer feature of pulp and isn't yet supported by their CLI. However, the capability is [exposed via the Pulp API](https://pulpproject.org/pulp_container/docs/admin/guides/pull-through-caching/) which I used to develop some quick & dirty scripts to [create](/scripts/create-cache.sh) and [delete](/scripts/delete-cache.sh) pull through caches. 

For interacting with the Pulp API to manage container config, I highly recommend looking at [pulp container's Rest API documention](https://pulpproject.org/pulp_container/restapi). For configuring pull through caches, you'll need to create a [pull through remote](https://pulpproject.org/pulp_container/restapi/#tag/Remotes:-Pull-Through) and a [pull through distribution](https://pulpproject.org/pulp_container/restapi/#tag/Distributions:-Pull-Through).

## Script Usage

Make the scripts executable:

```bash
chmod +x ./scripts/*.sh
```

Create a pull through cache for Docker Hub (default for pulp user argument `--user` is `admin`):

```bash
./scripts/create-cache.sh \
    --remote-name docker-cache \
    --remote-url https://registry-1.docker.io \
    --pulp-url https://pulp.local.zachary.day \
    --password <REPLACE_ME> 
```

You can skip this step if you just want to use the admin account. But if you want to create a user for consuming container artifacts, you can run the following:

*Note: The `configure-rbac.sh` script uses the pulp cli so you will need to add your pulp server & url credentials. To do so, run `pulp config create`*

```bash
./scripts/configure-rbac.sh \
    --user kubernetes \
    --group container-consumer \
    --password <REPLACE_ME> 
```

Can login via docker/podman cli:

```bash
docker login pulp.local.zachary.day
```

And then pull images:

```bash
docker pull pulp.local.zachary.day/docker-cache/calico/csi:v3.30.2
```

If you want to then delete a cache:

**Disclaimer: I have noticed that deleting and recreating a pull through cache can cause image pull issues with container repos. More specifically, let's say you create a pull through cache for docker hub and then proceed to pull some images. Then you delete that pull through cache and recreate it. There's a solid chance you'll have issues pulling images for repos that have been previously cached. I have not really dug into this super deeply, but my guess would be that the image repos will have some orphaned href associations to the deleted pull through remote/distribution. Easy solution is to just delete the pulp server and re-deploy it, but this is only suitable if you use pulp like I do - strictly for image caching. If pulp is a critical piece of infrastructure for storing your personal of company artifacts, you'll probably want to dig into the CLI.**

```bash
./scripts/delete-cache.sh \
    --remote-name docker-cache \
    --pulp-url https://pulp.local.zachary.day \
    --password <REPLACE_ME> 
```