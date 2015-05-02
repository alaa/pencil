require 'rest-client'

module Pencil
  class Consul

    def initialize(host:, port:)
      @host = host.nil? ? `hostname` : host
      @port = port
    end

    def register_service(service_name:, host_port:)
      uri = "http://#{host}:#{port}/v1/agent/service/register"
      body = { "ID" => service_name,
               "Name" => service_name,
               "Address" => host,
               "Port" => host_port.to_i }.to_json

      RestClient.put uri, body, :content_type => :json, :accept => :json
    end

    def get
      resource = "/catalog/node/#{host}"
      puts client.get(resource)
    end

    private
    attr_accessor :host, :port
  end
end
