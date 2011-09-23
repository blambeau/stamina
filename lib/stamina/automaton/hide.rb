module Stamina
  class Automaton

    # 
    # Returns a copy of self where all symbols in `alph` have been 
    # replaced by nil.
    #
    def hide(alph)
      dup.hide!(alph)
    end

    #
    # Replaces all symbols in `alph` by nil in this automaton.
    #
    def hide!(alph)
      new_alph = alphabet.to_a - alph.to_a
      h = Set.new(new_alph.to_a)
      each_edge do |edge|
        edge.symbol = nil unless h.include?(edge.symbol)
      end
      self.alphabet = new_alph
      self
    end

    # 
    # Returns a copy of self where all symbols not in `alph` have been 
    # replaced by nil.
    #
    def keep(alph)
      dup.keep!(alph)
    end

    #
    # Replaces all symbols not in `alph` by nil in this automaton.
    #
    def keep!(alph)
      hide!(self.alphabet.to_a - alph.to_a)
    end

  end # class Automaton
end # module Stamina
