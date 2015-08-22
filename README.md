# Pencil

Pencil is a simple service-registration tool for Docker and uses Consul as a backend for
Service-Discovery. It basically syncronizes the "diff" between the local state (Running Docker Containers)
and the remote state on Consul registry every (n) seconds. The default is set to 10s.

Pencil does not perform bulk syncing, it only syncronizes the changes the additions or deletions
to Consul which is highly important for external Load-balancing and service-monitoring.

## Building and Running Pencil:

Build the Docker image
```
docker build -t pencil .
```

Run it
```
docker run -d \
           -v /var/run/docker.sock:/tmp/docker.sock \
           pencil <consul-registry-address>
```

we need to mount the docker-engine socket into Pencil container in order to give it a privilige to
observe the contaners state on the host.

## SRV_ as a convention:

### Consul Tags:
You can pass array of strings to [Consul Tags](https://www.consul.io/docs/agent/http/agent.html#agent_service_register) using container environment variables.
All tags should start with `SRV_`
For example:  `docker run -P nginx -e "SRV_CLUSTER=staging"`


### Consul Service Name:
By default Pencil registers every docker contianer that exposes a `TCP Port`. and uses the
following convention for registering services on consul: `<docker-image-name>-<exposed-container-port>`.

For example: `docker run -P nginx` will let Pencil to register this container under the following name:
`nginx-80` as nginx image exposes TCP port `80`

If you wish to register your service as an alternative name, you can pass `SRV_NAME` to the container
and Pencil will use that string as the `preferred name` for consul registration.

For example: `docker run -P -e 'SRV_NAME=testing-microservice' nginx`

### Consul Health Check:
You can pass custom health check to Consul via docker container environment variables.
Pencil fills out the `host` and `port` dynamically on the run time. For example:

`docker run -P nginx -e "SRV_HEALTH_CHECK='curl -Ss http://%<host>s:%<port>s/health'"`

Pencil replaces the `host` with the value of `<consul-registry-address>` passed to the `agent`
and replaces the `port` dynamically by inspecting `container.PortMapping`

## TODO
- Refactoring
- Write tests

