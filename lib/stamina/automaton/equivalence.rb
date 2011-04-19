module Stamina
  class Automaton
    
    #
    # Checks if this automaton is equivalent to another one.
    #
    # Automata must be both minimal and complemented to guarantee that this method 
    # works.
    #
    def equivalent?(other, equiv = nil, key = :equiv_state)
      equiv ||= Proc.new{|s1,s2| (s1.accepting? == s2.accepting?) && 
                                 (s1.error? == s2.error?) && 
                                 (s1.initial? == s2.initial?) }

      # Both must already have basic attributes in common
      return false unless state_count==other.state_count
      return false unless edge_count==other.edge_count
      return false unless equiv[initial_state, other.initial_state]

      # We instantiate the decoration algorithm for checking equivalence on this
      # automaton:
      #   * decoration is the index of the equivalent state in other automaton
      #   * d0 is thus 'other.initial_state.index'
      #   * suppremum is identity and fails when the equivalent state is not unique
      #   * propagation checks transition function delta
      # 
      algo = Stamina::Utils::Decorate.new(key)
      algo.set_suppremum do |d0, d1|
        if (d0.nil? or d1.nil?)
           (d0 || d1)
        elsif d0==d1
          d0
        else
          raise Stamina::Abord
        end
      end
      algo.set_propagate do |d,e|
        reached = other.ith_state(d).dfa_step(e.symbol)
        raise Stamina::Abord if reached.nil?
        raise Stamina::Abord unless equiv[e.target, reached]
        reached.index
      end

      # Run the algorithm now
      begin
        algo.execute(self, nil, other.initial_state.index)
        return true
      rescue Stamina::Abord
        return false
      end
    end
    alias :<=> :equivalent?

  end # class Automaton
end # module Stamina
