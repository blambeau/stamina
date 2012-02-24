module Stamina
  class RegLang
    module Question
      include Node

      def to_fa!(fa)
        f1, t1 = fa.add_n_states(2)
        f2, t2 = self.term.to_fa!(fa)
        fa.connect(f1,f2,nil)
        fa.connect(t2,t1,nil)
        fa.connect(f1,t1,nil)
        [f1, t1]
      end

    end # module Question
  end # class RegLang
end # module Stamina