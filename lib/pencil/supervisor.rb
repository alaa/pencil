module Pencil
  class Supervisor
    def initialize(&runnable)
      @runnable = runnable
    end

    def start
      Pencil.logger.info("Supervisor: starting..")
      run
    end

    private

    attr_reader :runnable

    def run
      runnable.call
    rescue SystemExit, Interrupt
      raise
    rescue Exception => e
      Pencil.logger.error("Supervisor: rescued error #{e.inspect}")
      Pencil.logger.info("Supervisor: Restarting supervised block..")
      retry
    end
  end
end
