require 'docker'

module Pencil
  class Docker

    def initialize(hostname = 'localhost')
      @hostname = hostname
    end

    def observe
      containers = inspect_containers(list_running_containers)
      containers.each_with_object({}) do |container, acc|

        ports = container['NetworkSettings']['Ports']
        image = container['Config']['Image']
        container_id = container['Id'][0..8]
        acc[container_id] = {}

        ports.each do |service_port, host_port|
          unless host_port.nil?
            acc[container_id]['service_port'] = service_port.split('/')[0]
            acc[container_id]['host_port'] = host_port.first['HostPort']
            acc[container_id]["image"] = image
          end
        end

      end
    end

    private
    attr_accessor :hostname

    def list_running_containers
      ::Docker::Container.all
    end

    def inspect_containers(containers)
      containers.each_with_object([]) do |container, acc|
        acc << container.json
      end
    end
  end
end
