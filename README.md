# Pencil

Pencil is a simple service-discovery tool that meant to work with Docker and Consul.
It basically syncronize the "diff" between the local state (Running Docker Containers)
and the remote state on Consul registry every (n) seconds. the default is set to 10.

Pencil never does a bulk syncing but it only syncs the changes wheather they are (additions or deletions)
on the consul registry which is important for external Load-balancing or service-monitoring.

## Running Pencil (Recommended way)

```
$ docker run -d \
    -v /var/run/docker.sock:/tmp/docker.sock \
    alaa/pencil <consul-registry>
```

## Running Pencil wihtout Docker

- ``` https://github.com/alaa/pencil.git ```

- Run Consul cluster (4 nodes) on your machine:

- ``` scripts/start_consul_cluster ```

- Start Pencil

- ``` bin/agent <<ip_address>> ```

- Run few Nginx containers:

- ``` docker run -P nginx ```

Watch the changes on the stdout and on the consul web-ui.

# Custom Tags to register on Consul
Just pass an environment variable that starts with "SRV_". For example:
``` docker run -P nginx -e "SRV_CLUSTER=staging" ```

# Custom Health Checks for Consul
We can also pass custom health check to Consul via docker container environment variables.
Pencil fills out the `host` and `port` dynamicall on the run time. For example:

``` docker run -P nginx -e "SRV_HEALTH_CHECK='curl -Ss http://%<host>s:%<port>s/health'" ```
Pencil will replace the host with the ARGV[0] and the port will be filled dynamically from the
container.PortMapping array

## TODO

- Refactoring
- Add customizable consul health-checks
- write some tests
