module Stamina
  class RegLang
    module Node
    
      def to_fa
        from, to = to_fa!(fa = Automaton.new)
        from.initial!
        to.accepting!
        fa
      end

    end # module Node
  end # class RegLang
end # module Stamina

