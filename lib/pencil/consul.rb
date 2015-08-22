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

    def resync(containers)
      containers_ids = containers.keys
      consul_services_ids = get_registered_services_ids

      stale_containers = consul_services_ids - containers_ids
      deregister_services(stale_containers)

      new_containers_ids = containers_ids - consul_services_ids
      new_containers = containers.select{|key,value| new_containers_ids.include?(key)}
      register_services(new_containers)
    end

    private
    attr_accessor :host, :port, :endpoints

    def register_services(services)
      services.each do |id, options|
        register_service(service_id: id, options: options)
      end
    end

    def register_service(service_id:, options:)
      resource = endpoints.register_service(service_id: service_id,
                                            service_name: options['name'],
                                            host_port: options['host_port'],
                                            health_check: options['check'],
                                            health_check_interval: 5,
                                            tags: options['tags'])

      API::HTTP.request(body: resource)
      @logger.info "registering: #{service_id}"
    end

    def get_registered_services_ids
      resource = endpoints.services
      services = API::HTTP.request(body: resource)
      services.each_with_object([]) do |service, acc|
        acc << service.first
      end
    end

    def deregister_services(ids)
      ids.each do |id|
        deregister_service(id)
      end
    end

    def deregister_service(id)
      resource = endpoints.deregister_service(id)
      API::HTTP.request(body: resource)
      @logger.info "deregistering: #{id}"
    end

    def get_services_ids(containers)
      containers.each_with_object([]) do |(id, _), acc|
        acc << id
      end
    end
  end
end
