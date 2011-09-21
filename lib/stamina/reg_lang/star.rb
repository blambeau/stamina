module Stamina
  class RegLang
    module Star
      include Node
    
      def to_fa!(fa)
        from, to = term.to_fa!(fa)
        fa.connect(to, from, nil)
        fa.connect(from, to, nil)
        [from, to]
      end

    end # module Star
  end # class RegLang
end # module Stamina
