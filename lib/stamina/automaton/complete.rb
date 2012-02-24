module Stamina
  class Automaton

    #
    # Checks if this automaton is complete
    #
    def complete?
      alph = alphabet
      states.find{|s| !(alphabet - s.out_symbols).empty?}.nil?
    end

    #
    # Returns a completed copy of this automaton
    #
    def complete
      self.dup.complete!
    end

    #
    # Completes this automaton.
    #
    def complete!(sink_data = {:initial => false, :accepting => false, :error => false})
      alph = alphabet
      sink = add_state(sink_data)
      each_state do |s|
        out_symbols = s.out_symbols
        (alph-out_symbols).each do |symbol|
          connect(s, sink, symbol)
        end
      end
      drop_state(sink) if sink.adjacent_states == [sink]
      self
    end

  end # class Automaton
end # module Stamina