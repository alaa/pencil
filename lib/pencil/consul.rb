require 'consul/client'

module Pencil
  class Consul

    def initialize(host:, port:)
      @host = host.nil? ? `hostname` : host
      @client = ::Consul::Client.v1.http(host: host, port: port)
    end

    def get
      resource = "/catalog/node/#{host}"
      puts client.get(resource)
    end

    private
    attr_accessor :host, :client
  end
end
