# Pencil

Pencil is a simple service-registration tool for Docker and uses Consul as a backend for
Service-Discovery. It syncronizes only the delta `∆` between the local state on every node
(Running Docker Containers) and the remote state on Consul registry every (n) seconds.
The default is set to `10s`.

Pencil have been used in many different production systems and successfully synchronized hundreds of
thouthands of contianers without problems.

## Run Pencil from DockerHub image:
```
docker run -it -v /var/run/docker.sock:/var/run/docker.sock alaa/pencil:2 <consul-registry-address>
```

Or build the docker image yourself:

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

## SERVICE_ lable as a convention:

### Consul Tags:
You can pass array of strings to [Consul Tags](https://www.consul.io/docs/agent/http/agent.html#agent_service_register) using container environment variables.

- All tags should start with `SERVICE_`
- All tags keys should be passed as upper case letters as `SERVICE_TAG` not `SERVICE_tag`

- Tag keys should match the following regex: `/^SERVICE_[A-Z0-9-_]+[A-Z0-9]$/`
- Tag keys should be greater than `5 chars` and less than `40 chars`

- Tag values should match the following regex: `/^[a-z0-9-_]+[a-z0-9]$/`
- Tag values should be greater than `3 chars` and less than `200 chars`

For example:  `docker run -P -e "SERVICE_CLUSTER=staging_01" nginx`

### Consul Service Name:
By default Pencil registers every docker contianer that exposes a `TCP Port`. and uses the
following convention for registering services on consul: `<docker-image-name>-<exposed-container-port>`.

For example: `docker run -P nginx` will let Pencil to register this container under the following name:
`nginx-80` as nginx image exposes TCP port `80`

If you wish to register your service as an alternative name, you can pass `SERVICE_NAME` to the container
and Pencil will use that string as the `preferred name` for consul registration.

For example: `docker run -P -e 'SERVICE_NAME=testing-microservice' nginx`

### Consul Health Check:
You can pass custom health check to Consul via docker container environment variables.
Pencil fills out the `host` and `port` dynamically on the run time. For example:

##### HTTP HealthCheck example:
`docker run -P nginx -e "SERVICE_HEALTH_CHECK='curl -Ss http://%<host>s:%<port>s/health'"`

##### TCP HealthCheck example:
`docker run -P nginx -e "SERVICE_HEALTH_CHECK='nc -vz %<host>s %<port>s'"`

Pencil replaces the `host` with the value of `<consul-registry-address>` passed to the `agent`
and replaces the `port` dynamically by inspecting `container.PortMapping`

### Registering Consul Services on Nginx (Ingress) using Consul-Template.

The following example uses `SERVICE_` lables in a way to build nginx ingress rules:
I will exaplain here the lables I choose to use for this particular example:

`SERVICE_SCOPE`: If I want to register only public services on this ingress or only the internal services.

`SERVICE_TYPE` : If I want to configure HTTP or TCP or WebSockets in a specific blocks.

`SERVICE_NAME` : The service name I choose to use as sub-domain on the ingress config: i.e: nginx virtual host

`SERVICE_ACL` : If I want to pass service Access List, especeially if I am exposing or registering this services on a public nginx ingress.

`@upstream_domain` and `@server_name`: These are just variables can be configured to set the domain name you wish to expose your ingress on.
You can replace these variavles starting with `@` to your desired static values.


```
{{ range services }}
{{ $tags := .Tags | join "," }}
  {{ if $tags | regexMatch "SERVICE_SCOPE=public" }}

    {{ if $tags | regexMatch "SERVICE_TYPE=(http)" }}
      {{ $services := service .Name }}
      {{ $len := len $services }}
        {{ if gt $len 0 }}
          upstream {{.Name}}.<%=@upstream_domain%> {
          {{ range service .Name }}
            server {{.Address}}:{{.Port}};
          {{end}}
          }
        {{end}}
    {{ end }}

  {{ end }}
{{ end }}

{{ range services }}
{{ $tags := .Tags | join "," }}
  {{ if $tags | regexMatch "SERVICE_SCOPE=public" }}

    {{ if $tags | regexMatch "SERVICE_TYPE=(http)" }}
      {{ $services := service .Name }}
      {{ $len := len $services }}
        {{ if gt $len 0 }}
        server {
          server_name <%=@server_names%>;

          # Fetch Service ACL
          {{range $tag := .Tags}}
            {{ if $tag | regexMatch "SERVICE_ACL" }}
              {{ $acls := (index ($tag | split "=") 1) | split "," }}
                {{ range $acls }} allow {{ . }}; {{ end }}
                  deny all;
            {{end}}
          {{end}}

          location / {
            proxy_pass http://{{.Name}}.<%=@upstream_domain%>;
          }
        }
        {{end}}
    {{ end }}
  {{ end }}
{{ end }}
```

## TODO
- Refactoring
- Write tests
