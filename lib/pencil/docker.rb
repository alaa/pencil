require 'docker'

module Pencil
  class Docker

    def initialize(host:)
      @host = host
    end

    def all
      containers = inspect_containers(list_running_containers)
      containers.each_with_object({}) do |container, acc|

        ports = container['NetworkSettings']['Ports']
        image = container['Config']['Image']
        cid = container['Id']
        env = container['Config']['Env']
        tags = extract_tags(env)

        ports.each do |service_port, host_port|
          unless host_port.nil?
            s_port = service_port.split('/').first
            h_port = host_port.first['HostPort']

            acc[cid] = {}
            acc[cid]['service_port'] = s_port
            acc[cid]['host_port'] = h_port
            acc[cid]["image"] = image
            acc[cid]["tags"] = tags
            acc[cid]["check"] = check(tags, host, h_port)
            acc[cid]["name"] = service_name(tags, image, s_port)
          end
        end
      end
    end

    private
    attr_accessor :host

    def list_running_containers
      ::Docker::Container.all
    end

    def inspect_containers(containers)
      containers.each_with_object([]) do |container, acc|
        acc << container.json
      end
    end

    def extract_tags(env_vars)
      env_vars.each_with_object([]) do |var, tags|
        var =~ /^SRV_/ ? tags << var : ""
      end
    end

    # Construct Service Name
    def service_name(tags, image, port)
      tags.each do |tag|
        if tag =~ /^SRV_NAME/
          name = tag.split('=')[1]
          return name
        end
      end
      service_default_name(image, port)
    end

    def service_default_name(image, port)
      image.split('/').last.split(':').first + '-' + port
    end

    # Construct Check script
    def check(tags, host, port)
      tags.each_with_object([]) do |tag, checks|
        if tag =~ /^SRV_HEALTH_CHECK/
          script = tag.split('=')[1]
          return check_formatter(script, host, port)
        end
      end
      check_formatter(default_health_check_script, host, port)
    end

    def check_formatter(script, host, port)
      sprintf(script, {host: host, port: port})
    end

    def default_health_check_script
      "curl -Ss http://%<host>s:%<port>s"
    end
  end
end
