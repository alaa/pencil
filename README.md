# Pencil

Pencil is a simple service-discovery tool that meant to work with Docker and Consul.
It basically syncronize the "diff" between the local state (Running Docker Containers)
and the remote state on Consul registry every (n) seconds. the default is set to 10.

Pencil never does a bulk syncing but it only syncs the changes wheather they are (additions or deletions)
on the consul registry which is important for external Load-balancing or service-monitoring.

## Installation

- ``` https://github.com/alaa/pencil.git ```

- Run Consul cluster (4 nodes) on your machine:

- ``` scripts/start_consul_cluster ```

- Start Pencil

- ``` bin/agent <<ip_address>> ```

- Run few Nginx containers:

- ``` docker run -P nginx ```

Watch the changes on the stdout and on the consul web-ui.

## TODO

- Refactoring
- Add customizable consul health-checks
- write some tests
