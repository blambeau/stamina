module Stamina
  module Dsl
    module RegLang

      #
      # Coerces `arg` to a regular language.
      # 
      def regular(arg)
        Stamina::RegLang.coerce(arg)
      end

      #
      # Returns the universal language on a given alphabet.
      #
      def sigma_star(alphabet)
        Stamina::RegLang.sigma_star(alphabet)
      end

      #
      # Coerces `arg` to a prefix-closed regular language.
      #
      def prefix_closed(arg)
        regular(arg).prefix_closed
      end

    end # module RegLang
    include RegLang
  end # module Dsl
end # module Stamina
