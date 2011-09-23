module Stamina
  class RegLang
    module Sequence
      include Node
    
      def to_fa!(fa)
        f1, t1 = self.head.to_fa!(fa)
        f2, t2 = self.tail.to_fa!(fa)
        fa.connect(t1, f2, nil)
        [f1, t2]
      end

    end # module Sequence
  end # class RegLang
end # module Stamina
