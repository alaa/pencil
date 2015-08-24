$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'pencil/docker'
require 'pencil/consul_api_http'
require 'pencil/consul_endpoints'
require 'pencil/consul'
require 'pencil/agent'
require 'pencil/logging'

module Pencil
  include Logging

  class Version
    VERSION = '0.2'

    def self.to_s
      "Running Pencil version #{VERSION}"
    end
  end
end
