module Pencil
  class Consul
    module API
      class HTTP
        def self.request(body:)
          case body[:method]
          when :get
            resp = RestClient.get(body[:uri])
            JSON.parse(resp) if resp.size > 0

          when :put
            resp = RestClient.put(body[:uri],
                                  body[:body],
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
