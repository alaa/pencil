module Pencil
  class Consul
    module API
      class HTTP
        def self.request(resource: resource)
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
            fail InvalidHTTPMethod
          end
        end

        private

        class Consul::API::HTTP::InvalidHTTPMethod < Exception; end
      end
    end
  end
end
