module Stamina
  class RegLang
    module Alternative
      include Node
    
      def to_fa!(fa)
        from, to = fa.add_n_states(2)
        f1, t1 = self.head.to_fa!(fa)
        f2, t2 = self.tail.to_fa!(fa)
        fa.connect(from, f1, nil)
        fa.connect(from, f2, nil)
        fa.connect(t1, to, nil)
        fa.connect(t2, to, nil)
        [from, to]
      end

    end # module Alternative
  end # class RegLang
end # module Stamina
