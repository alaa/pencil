module Pencil
  class Consul

    Endpoints = Struct.new(:host, :port) do
      def consul_url
        "http://#{host}:#{port}"
      end

      def consul_register_service_uri
        consul_url + "/v1/agent/service/register"
      end

      def consul_deregister_service_uri(service_id)
        consul_url + "/v1/agent/service/deregister/#{service_id}"
      end

      def consul_services_uri
        consul_url + "/v1/agent/services"
      end
    end

  end
end
