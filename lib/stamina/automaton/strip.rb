module Stamina
  class Automaton

    # Removes unreachable states from the initial ones
    def strip!
      depth(:reachable)
      drop_states(*states.select{|s| s[:reachable].nil?})
    end

    # Returns a copy of this automaton with unreachable states removed
    def strip
      dup.strip!
    end

  end # class Automaton
end # module Stamina