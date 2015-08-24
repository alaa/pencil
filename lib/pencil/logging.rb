require 'logger'

module Pencil
  module Logging
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def logger
        logger ||= Logger.new(STDOUT)
        logger.formatter = proc do |severity, datetime, progname, msg|
          "#{datetime.strftime('%Y-%m-%d %H:%M:%S')} [#{severity}] #{msg}\n"
        end
        logger
      end
    end

    def logger
      Logging.logger
    end
  end
end
