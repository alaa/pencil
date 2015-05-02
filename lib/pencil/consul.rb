require 'rest-client'

module Pencil
  class Consul

    def initialize(host:, port:)
      @host = host.nil? ? `hostname` : host
      @port = port
    end

    def register_service(service_id:, service_name:, host_port:)
      uri = "http://#{host}:#{port}/v1/catalog/register"
      body = {
        "Datacenter" => "dc1",
        "Node" => host,
        "Address" => '127.0.0.1',

        "Service" => {
          "ID" => service_id,
          "Service" => service_name,
          "Address" => host,
          "Port" => host_port.to_i
        }
      }.to_json

      RestClient.put uri, body, :content_type => :json, :accept => :json
    end

    def deregister_service(service_name)
      uri = "http://#{host}:#{port}/v1/catalog/deregister"
      body = { "Datacenter" => 'dc1',
               "Node" => host,
               "ServiceID" => service_name }.to_json

      RestClient.put uri, body, :content_type => :json, :accept => :json
    end

    private
    attr_accessor :host, :port
  end
end
