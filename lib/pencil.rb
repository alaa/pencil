$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'pencil/docker'
require 'pencil/consul_api_http'
require 'pencil/consul_endpoints'
require 'pencil/consul'
require 'pencil/agent'

module Pencil
  class Version
    VERSION = '0.1'

    def self.to_s
      "Running Pencil version #{VERSION}"
    end
  end
end
