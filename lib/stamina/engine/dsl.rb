module Stamina
  class Engine
    module DSL

      def regular(str)
        RegLang.parse(str)
      end

    end # module DSL
  end # class Engine
end # module Stamina
