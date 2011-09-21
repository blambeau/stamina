module Stamina
  class RegLang
    module Node
    
      def to_fa
        from, to = to_fa!(fa = Automaton.new)
        from.initial!
        to.accepting!
        fa
      end
    
      def to_dfa
        to_fa.to_dfa
      end
    
      def to_cdfa
        to_fa.to_cdfa
      end

    end # module Node
  end # class RegLang
end # module Stamina

