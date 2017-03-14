# Setup consul cluster

# remove old containers
docker rm -f node1 client

# start consul server
docker run -d --name node1 -h node1 progrium/consul -server -bootstrap-expect 1
JOIN_IP="$(docker inspect -f '{{.NetworkSettings.IPAddress}}' node1)"

# start consul client
# Note: Make sure dnsmasq on 53/udp is turned off.
docker run -it --net=host --name client -h client progrium/consul -join $JOIN_IP
