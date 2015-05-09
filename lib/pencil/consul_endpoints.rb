module Pencil
  class Consul

    Endpoints = Struct.new(:host, :port) do
      def url
        "http://#{host}:#{port}"
      end

      def register_service(service_id:, service_name:, host_port:)
        { uri: url + "/v1/agent/service/register",
          method: :put,
          :body => {
            "ID" => service_id,
            "Name" => service_name,
            "Port" => host_port.to_i,
            "Check" => {
              "Script" => "curl -Ss http://#{host}:#{host_port}",
              "Interval" => "5s",
            }
          }.to_json
        }
      end

      def deregister_service(service_id)
        { uri: url + "/v1/agent/service/deregister/#{service_id}",
          method: :get }
      end

      def services
        { uri: url + "/v1/agent/services",
          method: :get }
      end
    end
  end
end
