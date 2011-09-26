module Stamina
  module Abbadingo
    #
    # Generates a random DFA using the Abbadingo protocol.
    # 
    class RandomDFA

      def execute(state_count = 64, accepting_ratio = 0.5)
        dfa = Automaton.new
        
        # Generate 5/4*state_count states
        (state_count.to_f * 5.0 / 4.0).to_i.times do 
          dfa.add_state(:initial   => false,
                        :accepting => (Kernel.rand <= accepting_ratio),
                        :error     => false)
        end

        # Generate all edges
        dfa.each_state do |source|
          ["0", "1"].each do |symbol|
            target = dfa.ith_state(Kernel.rand(dfa.state_count))
            dfa.connect(source, target, symbol)
          end
        end

        # Choose an initial state
        dfa.ith_state(Kernel.rand(dfa.state_count)).initial!
        
        # Minimize the automaton and return it
        Stamina::Automaton::Minimize::Pitchies.execute(dfa)
      end

    end # class RandomDFA
  end # module Abbadingo
end # module Stamina

