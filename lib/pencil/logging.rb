require 'logger'

module Pencil
  module Logging
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def logger
        STDOUT.sync = true
        logger ||= Logger.new(STDOUT)
        logger.formatter = proc do |severity, datetime, progname, msg|
          "[pencil] #{datetime.strftime('%Y-%m-%d %H:%M:%S')} [#{severity}] #{msg}\n"
        end
        logger
      end
    end

    def logger
      Logging.logger
    end
  end
end
