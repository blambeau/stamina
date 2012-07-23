module Stamina
  class Automaton

    #
    # Checks if this automaton is equivalent to another one.
    #
    # Automata must be both minimal and complete to guarantee that this method
    # works.
    #
    def equivalent?(other, equiv = nil, key = :equiv_state)
      equiv ||= Proc.new{|s1,s2| (s1 && s2) &&
                                 (s1.accepting? == s2.accepting?) &&
                                 (s1.error? == s2.error?) &&
                                 (s1.initial? == s2.initial?) }

      # Both must already have basic attributes in common
      return false unless state_count==other.state_count
      return false unless edge_count==other.edge_count
      return false unless alphabet==other.alphabet
      return false unless equiv[initial_state, other.initial_state]

      # We instantiate the decoration algorithm for checking equivalence on this
      # automaton:
      #   * decoration is the index of the equivalent state in other automaton
      #   * d0 is thus 'other.initial_state.index'
      #   * suppremum is identity and fails when the equivalent state is not unique
      #   * propagation checks transition function delta
      #
      algo = Stamina::Utils::Decorate.new
      algo.set_suppremum do |d0, d1|
        if (d0.nil? or d1.nil?)
           (d0 || d1)
        else
          throw :non_equivalent unless d0==d1
          d0
        end
      end
      algo.set_initiator{|s| s.initial? ? other.initial_state.index : nil}
      algo.set_start_predicate{|s| s.initial? }
      algo.set_propagate do |d,e|
        reached = other.ith_state(d).dfa_step(e.symbol)
        throw :non_equivalent unless reached && equiv[e.target, reached]
        reached.index
      end

      # Run the algorithm now
      catch(:non_equivalent) do
        algo.call(self, key)
        return true
      end
      return false
    end
    alias :<=> :equivalent?

  end # class Automaton
end # module Stamina