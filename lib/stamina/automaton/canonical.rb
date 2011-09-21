module Stamina
  class Automaton

    def canonical
      determinize.complete.minimize
    end

  end # class Automaton
end # module Stamina
