module Stamina
  class RegLang
    module Question
      include Node
    
      def to_fa!(fa)
        from, to = term.to_fa!(fa)
        fa.connect(from, to, nil)
        [from, to]
      end

    end # module Question
  end # class RegLang
end # module Stamina
