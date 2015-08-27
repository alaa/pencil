require 'docker'

module Pencil
  class Docker
    def initialize(host:)
      @host = host
    end

    def all
      containers = inspect_containers(list_running_containers)
      containers.each_with_object({}) do |container, acc|

        ports = container['NetworkSettings']['Ports'] || []
        image = container['Config']['Image']
        cid = container['Id']
        env = container['Config']['Env'] || []
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

    # Construct and validate Tags
    def extract_tags(env_vars)
      env_vars.each_with_object([]) do |var, tags|
        parts = var.split('=')
        tag_key, tag_value = parts[0], parts[1]

        if tag_key == "SERVICE_HEALTH_CHECK"
          valid_tag_key?(tag_key) ? tags << var : ""
        end

        if valid_tag_key?(tag_key) && valid_tag_value?(tag_value)
          tags << var
        end
      end
    end

    def valid_tag_value?(name)
      !name.nil? &&
        name.length.between?(3, 40) &&
        !(name =~ /^[a-z0-9\-_]+[a-z0-9]$/).nil?
    end

    def valid_tag_key?(tag_key)
      !tag_key.nil? &&
        tag_key.length.between?(9, 40) &&
        !(tag_key =~ /^SERVICE_[A-Z0-9\-_]+[A-Z0-9]$/).nil?
    end

    # Construct Service Name
    def service_name(tags, image, port)
      tags.each do |tag|
        if tag =~ /^SERVICE_NAME=/
          name = tag.split('=')[1]
          return name
        end
      end
      service_default_name(image, port)
    end

    def service_default_name(image, port)
      image.split('/').last.split(':').first + '-' + port
    end

    # Construct HealthCheck script
    def check(tags, host, port)
      tags.each_with_object([]) do |tag, checks|
        if tag =~ /^SERVICE_HEALTH_CHECK/
          script = tag.split('=')[1]
          return check_formatter(script, host, port)
        end
      end
      check_formatter(default_health_check_script, host, port)
    end

    def check_formatter(script, host, port)
      sprintf(script, {host: host, port: port})
    rescue => e
      Pencil.logger.error(e.message)
      check_formatter(default_health_check_script, host, port)
    end

    def default_health_check_script
      "curl -Ss http://%<host>s:%<port>s"
    end
  end
end
