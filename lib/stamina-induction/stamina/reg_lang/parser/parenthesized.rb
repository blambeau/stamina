module Stamina
  class RegLang
    module Parenthesized
      include Node

      def to_fa!(fa)
        self.expr.to_fa!(fa)
      end

    end # module Parenthesized
  end # class RegLang
end # module Stamina