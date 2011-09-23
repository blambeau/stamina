module Stamina
  module Dsl
    module RegLang

      EMPTY_LANG = ::Stamina::RegLang::EMPTY

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

      # 
      # Hides allbut `alph` symbols in the regular language `arg`
      # 
      def project(arg, alph)
        regular(arg).project(alph)
      end

      # 
      # Hides `alph` symbols in the regular language `arg`
      # 
      def hide(arg, alph)
        regular(arg).hide(alph)
      end

    end # module RegLang
    include RegLang
  end # module Dsl
end # module Stamina
