module Pencil
  class Consul

    class APIclient
      def self.http(resource: resource)
        case resource[:method]
        when :get
          resp = RestClient.get(resource[:uri])
          JSON.parse(resp) if resp.size > 2

        when :put
          resp = RestClient.put(resource[:uri],
                                resource[:body],
                                content_type: :json,
                                accept: :json)
        else
          fail InvalidMethod
        end
      end

      private

      class Consul::APIclient::InvalidMethod < Exception; end
    end
  end
end
