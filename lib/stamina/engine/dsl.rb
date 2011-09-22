module Stamina
  class Engine
    module DSL

      ### samples and induction

      def sample(str)
        Sample.parse(str)
      end

      def rpni(sample)
        Induction::RPNI.execute(sample)
      end

      ### regular languages

      def regular(str)
        RegLang.parse(str)
      end

      def prefix_closed(str)
        RegLang.parse(str).prefix_closed
      end

    end # module DSL
  end # class Engine
end # module Stamina
