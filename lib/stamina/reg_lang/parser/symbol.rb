module Stamina
  class RegLang
    module Symbol
      include Node

      def to_fa!(fa)
        from, to = fa.add_n_states(2, :initial => false, :accepting => false)
        fa.connect(from, to, to_s)
        [from, to]
      end

    end # module Symbol
  end # class RegLang
end # module Stamina
