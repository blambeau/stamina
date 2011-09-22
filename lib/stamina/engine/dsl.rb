module Stamina
  class Engine
    module DSL

      def regular(str)
        RegLang.parse(str)
      end

      def prefix_closed(str)
        RegLang.parse(str).prefix_closed
      end

    end # module DSL
  end # class Engine
end # module Stamina
