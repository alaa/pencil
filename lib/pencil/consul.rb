require 'rest-client'
require 'logger'

module Pencil
  class Consul
    def initialize(host:, port:)
      @host = host
      @port = port
      @endpoints = Endpoints.new(host, port)
      @logger = Logger.new(STDOUT)
    end

    def resync(local_services)
      services = Services.new(local_services.keys, get_registered_services)
      deregister_services(services.to_deregister)
      register_services(local_services, services.to_register)
    end

    private
    attr_accessor :host, :port, :endpoints

    def register_services(services, new_services)
      services_data = services.select do |key, value|
        new_services.include?(key)
      end

      services_data.each do |id, options|
        register_service(service_id: id, options: options)
      end
    end

    def register_service(service_id:, options:)
      service_name = consul_image_name(options['image'], options['service_port'])

      service_check = health_check(options['env'], options['host_port'])

      resource = endpoints.register_service(service_id: service_id,
                                            service_name: service_name,
                                            host_port: options['host_port'],
                                            health_check: service_check,
                                            health_check_interval: 5,
                                            tags: pencil_env(options['env']))

      API::HTTP.request(resource: resource)
      @logger.info "registering: #{service_id}"
    end

    def get_registered_services
      resource = endpoints.services
      services = API::HTTP.request(resource: resource)
      services.each_with_object([]) do |service, acc|
        acc << service.first
      end
    end

    # Extract pencil related variables starting with SRV_
    def pencil_env(env)
      vars = []
      env.each do |e|
        e =~ /^SRV_/i ? vars << e : ""
      end
      vars
    end

    # Extract health check script from env, if not passed fall back to the
    # default health check
    def health_check(env, port)
      hash = Hash.new
      vars = pencil_env(env)

      vars.each do |var|
        key, value = var.split('=')
        hash[key] = value
      end

      if hash.has_key?('SRV_HEALTH_CHECK')
        return check_formatter(hash['SRV_HEALTH_CHECK'], host, port)
      end

      check_formatter("curl -Ss %<host>s:%<port>s", host, port)
    end

    # Replace Check variables references with their corresponding values
    def check_formatter(script, host, port)
      sprintf(script, {host: host, port: port})
    end

    def deregister_services(ids)
      ids.each do |id|
        deregister_service(id)
      end
    end

    def deregister_service(id)
      resource = endpoints.deregister_service(id)
      API::HTTP.request(resource: resource)
      @logger.info "deregistering: #{id}"
    end

    def get_services_ids(local_services)
      local_services.each_with_object([]) do |(id, options), acc|
        acc << id
      end
    end

    def consul_image_name(name, port)
      name.split('/').last.split(':').first + '-' + port
    end

    Services = Struct.new(:local_services, :remote_services) do
      def to_register
        local_services - remote_services
      end

      def to_deregister
        remote_services - local_services
      end
    end
  end
end
