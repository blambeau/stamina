module Stamina
  class Engine
    module DSL

      def assert(x, msg = nil)
        unless x
          raise "Assertion failed: #{msg || 'no message provided'}"
        end
      end

      ### regular languages

      def regular(str)
        RegLang.parse(str)
      end

      def sigma_star(*args)
        RegLang.sigma_star(*args)
      end

      def prefix_closed(str)
        RegLang.parse(str).prefix_closed
      end

      ### samples and induction

      def sample(str)
        Sample.parse(str)
      end

      def rpni(sample)
        Induction::RPNI.execute(sample)
      end

      def blue_fringe(sample)
        Induction::BlueFringe.execute(sample)
      end

    end # module DSL
  end # class Engine
end # module Stamina
