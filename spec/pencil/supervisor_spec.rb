module Pencil
  RSpec.describe Supervisor do
    class ObscureError < Exception; end

    let(:supervisor) do
      switch = false
      Supervisor.new do
        events << :started

        if switch
          events << :raise_interrupt
          raise Interrupt
        end

        switch = true
        events << :raise_error
        raise ObscureError
      end
    end

    let(:events) { [] }

    it "handles failure correctly" do
      expect do
        supervisor.start
      end.to raise_error(Interrupt)

      expect(events).to eq([
        :started,
        :raise_error,
        :started,
        :raise_interrupt,
      ])
    end
  end
end
