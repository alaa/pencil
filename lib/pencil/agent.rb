module Pencil
  class Agent
    def self.run(docker:, backend:, interval:)
      while true do
        backend.resync(docker.all)
        sleep interval
      end
    end
  end
end
