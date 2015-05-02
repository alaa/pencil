require 'docker'

module Pencil
  class Docker

    def initialize(hostname = 'localhost')
      @hostname = hostname
    end

    def resync
      containers = inspect_containers(list_running_containers)
      containers.each_with_object({}) do |container, acc|

        ports = container['NetworkSettings']['Ports']
        image = container['Config']['Image']
        cid = container['Id'][0..8]

        ports.each do |service_port, host_port|
          unless host_port.nil?
            acc[cid] = {}
            acc[cid]['service_port'] = service_port.split('/').first
            acc[cid]['host_port'] = host_port.first['HostPort']
            acc[cid]["image"] = image
          end
        end

      end
    end

    def get_killed
      puts "looking into docker events"
      ::Docker::Event.since (Time.now.to_i - 5) do |event|
        if event.status == 'die'
          dead_container = ::Docker::Container.get(event.id)
          puts dead_container.info['Image']
          break;
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
