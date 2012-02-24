module Stamina
  class Automaton

    #
    # Returns the complement automaton.
    #
    # A complement automaton is simply a complete automaton with all state
    # labels flipped.
    #
    def complement
      dup.complement!
    end

    #
    # Complements this automaton
    #
    def complement!
      complete!
      each_state do |s|
        s[:accepting] = !s.accepting?
      end
      self
    end

  end # class Automaton
end # module Stamina