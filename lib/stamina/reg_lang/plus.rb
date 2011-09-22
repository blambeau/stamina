module Stamina
  class RegLang
    module Plus
      include Node
    
      def to_fa!(fa)
        from, to = self.term.to_fa!(fa)
        fa.connect(to, from, nil)
        [from, to]
      end

    end # module Plus
  end # class RegLang
end # module Stamina
