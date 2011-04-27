module Stamina
  class Automaton
    
    #
    # Checks if this automaton is minimal.
    #
    def minimal?
      self.minimize <=> self.complement
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
