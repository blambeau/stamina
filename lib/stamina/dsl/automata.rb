module Stamina
  module Dsl
    module Automata

      #
      # Coerces `arg` to an automaton
      #
      def automaton(arg)
        Automaton.coerce(arg)
      end

    end # module Automata
    include Automata
  end # module Dsl
end # module Stamina
