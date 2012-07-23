module Stamina
  class Automaton

    # Implements the equivalence relation commonly used on canonical DFAs
    class Equivalence < TransitionSystem::Equivalence

      def equivalent_systems?(s, t)
        (s.state_count == t.state_count) &&
        (s.edge_count  == t.edge_count)  &&
        (s.alphabet    == t.alphabet)    &&
        (s.data        == t.data)
      end

      def equivalent_states?(s, t)
        (s.initial?   == t.initial?) &&
        (s.accepting? == t.accepting?) &&
        (s.error?     == t.error?)
      end

      def equivalent_edges?(e, f)
        e.symbol == f.symbol
      end

    end # class Equivalence

    #
    # Checks if this automaton is equivalent to another one.
    #
    # Automata must be both minimal and complete to guarantee that this method
    # works.
    #
    def equivalent?(other)
      Equivalence.new.call(self, other)
    end
    alias :<=> :equivalent?

  end # class Automaton
end # module Stamina