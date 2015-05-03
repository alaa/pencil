require 'rest-client'

module Pencil
  class Consul

    def initialize(host:, port:)
      @host = host.nil? ? `hostname` : host
      @port = port
    end

    def get_ids(local_containers)
      local_containers.each_with_object([]) do |(k, v), acc|
        acc << "#{v['image']}:#{k}"
      end
    end

    def resync(local_containers)
      ids = get_ids(local_containers)
      registered_containers = get_registered_containers

      zombies = registered_containers - ids
      zombies.each do |zombie|
        puts "deregistering #{zombie}" if deregister_service(zombie)
      end

    end

    def deregister_service(id)
      uri = "http://#{host}:#{port}/v1/agent/service/deregister/#{id}"
      RestClient.get uri
    end

    def register_service(service_id:, service_name:, host_port:)
      puts "== syncing #{service_id}"

      uri = "http://#{host}:#{port}/v1/agent/service/register"
      body = {
        "ID" => "#{service_name}:#{service_id}",
        "Name" => service_name,
        "Port" => host_port.to_i,
        "Check" => {
          "Script" => "curl -Ss http://#{host}:#{host_port}",
          "Interval" => "10s",
        }
      }.to_json

      RestClient.put uri, body, :content_type => :json, :accept => :json
    end

    def get_registered_containers
      uri = "http://#{host}:#{port}/v1/agent/services"
      resp = RestClient.get uri

      services = JSON.parse(resp)
      services.each_with_object([]) do |service, acc|
        acc << service.first
      end
    end

    private
    attr_accessor :host, :port
  end
end
