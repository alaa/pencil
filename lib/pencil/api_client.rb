module Pencil
  class Consul

    class APIclient
      def self.http(method:, uri:, body: nil)
        case method
        when :get
          resp = RestClient.get(uri)
          JSON.parse(resp) if resp.size > 2
        when :put
          resp = RestClient.put(uri, body, content_type: :json, accept: :json)
        else
          fail InvalidMethod
        end
      end

      private

      class Consul::APIclient::InvalidMethod < Exception; end
    end

  end
end
