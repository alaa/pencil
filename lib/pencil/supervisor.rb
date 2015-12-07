module Pencil
  class Supervisor
    MIN_SLEEP_SECONDS = 2
    MAX_SLEEP_SECONDS = 120
    FAILURE_IN_ROW_SECONDS = 10

    def initialize(&runnable)
      @runnable = runnable
      @last_failure = nil
      @sleep_time = MIN_SLEEP_SECONDS
    end

    def start
      Pencil.logger.info("Supervisor: starting..")
      run
    end

    private

    attr_reader :runnable, :sleep_time, :last_failure

    def run
      runnable.call
    rescue SystemExit, Interrupt
      raise
    rescue Exception => e
      Pencil.logger.error("Supervisor: rescued error #{e.inspect}")
      update_sleep_time
      Pencil.logger.info("Supervisor; Sleeping for #{sleep_time}..")
      sleep(sleep_time)
      Pencil.logger.info("Supervisor: Restarting supervised block..")
      record_failure
      retry
    end

    def update_sleep_time
      @sleep_time = [new_sleep_time, MAX_SLEEP_SECONDS].min
    end

    def record_failure
      @last_failure = Time.now
    end

    def new_sleep_time
      return MIN_SLEEP_SECONDS unless last_failure
      return MIN_SLEEP_SECONDS unless failure_in_row?
      sleep_time * 2
    end

    def failure_in_row?
      Time.now - last_failure <= FAILURE_IN_ROW_SECONDS
    end
  end
end
