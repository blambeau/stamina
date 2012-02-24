module Stamina
  module Dsl
    module Automata

      #
      # Coerces `arg` to an automaton
      #
      def automaton(arg)
        Automaton.coerce(arg)
      end

      #
      # Computes the synchronous composition of many automata
      #
      def compose(*args)
        automata = args.collect{|a| automaton(a)}
        Stamina::Automaton::Compose.execute(automata)
      end

    end # module Automata
    include Automata
  end # module Dsl
end # module Stamina