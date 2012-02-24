module Stamina
  class Automaton

    #
    # Checks if this automaton is minimal.
    #
    def minimal?
      self.minimize.state_count == self.state_count
    end

    #
    # Returns a minimized version of this automaton.
    #
    # This method should only be called on deterministic automata.
    #
    def minimize(options = {})
      Minimize::Hopcroft.execute(self, options)
    end

  end # class Automaton
end # module Stamina
require 'stamina/automaton/minimize/hopcroft'
require 'stamina/automaton/minimize/pitchies'