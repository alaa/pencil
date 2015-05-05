require 'rest-client'
require 'logger'

module Pencil
  class Consul

    def initialize(host:, port:)
      @host = host.nil? ? `hostname` : host
      @port = port
      @consul_uri = "http://#{host}:#{port}"
      @logger = Logger.new(STDOUT)
    end

    def resync(containers)
      containers_ids = containers.keys
      @logger.info("local container: #{containers_ids}")
      registered_containers = get_registered_containers

      stale_containers = registered_containers - containers_ids
      @logger.info("stale containers: #{stale_containers}")
      deregister_containers(stale_containers)

      new_containers = containers_ids - registered_containers
      @logger.info("new containers: #{new_containers}")
      register_containers(containers, new_containers)
    end

    private
    attr_accessor :host, :port, :consul_uri

    def consul_image_name(name, port)
      name.split('/').last.split(':').first + '-' + port
    end

    def register_containers(containers, new_containers)
      containers.each_pair do |key, value|
        if new_containers.include?(key)
          register_container(container_id: key,
                             image_name: value['image'],
                             host_port: value['host_port'],
                             service_port: value['service_port'])
        end
      end
    end

    def register_container(container_id:, image_name:, host_port:, service_port:)
      puts "+++ " + container_id
      uri = consul_uri + "/v1/agent/service/register"

      body = {
        "ID" => container_id,
        "Name" => consul_image_name(image_name, service_port),
        "Port" => host_port.to_i,
        "Check" => {
          "Script" => "curl -Ss http://#{host}:#{host_port}",
          "Interval" => "10s",
        }
      }.to_json

      resp = RestClient.put uri, body, :content_type => :json, :accept => :json
      @logger.info("Consul response: #{resp}")
    end

    def get_registered_containers
      uri = consul_uri + "/v1/agent/services"
      resp = RestClient.get uri

      services = JSON.parse(resp)
      services.each_with_object([]) do |service, acc|
        acc << service.first
      end
    end

    def get_containers_ids(local_containers)
      local_containers.each_with_object([]) do |(id, options), ids|
        ids << id
      end
    end

    def deregister_containers(ids)
      ids.each do |id|
        deregister_container(id)
      end
    end

    def deregister_container(id)
      uri = consul_uri + "/v1/agent/service/deregister/#{id}"
      puts "--- #{id}"
      RestClient.get uri
    end
  end
end
