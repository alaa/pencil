require 'rest-client'

module Pencil
  class Consul

    def initialize(host:, port:)
      @host = host.nil? ? `hostname` : host
      @port = port
    end

    def register_service(service_id:, service_name:, host_port:)
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

      puts body
      RestClient.put uri, body, :content_type => :json, :accept => :json
    end

    private
    attr_accessor :host, :port
  end
end
