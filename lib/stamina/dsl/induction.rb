module Stamina
  module Dsl
    module Induction

      #
      # Coerces `arg` to a Sample
      #
      def sample(arg)
        Sample.coerce(arg)
      end

      #
      # Learn a regular language from `arg` using the RPNI algorithm.
      #
      def rpni(arg)
        regular Stamina::Induction::RPNI.execute(sample(arg))
      end

      #
      # Learn a regular language from `arg` using the RPNI algorithm.
      #
      def blue_fringe(arg)
        regular Stamina::Induction::BlueFringe.execute(sample(arg))
      end

    end # module Induction
    include Induction
  end # module Dsl
end # module Stamina