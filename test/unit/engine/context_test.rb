module Stamina
  class Engine
    class ContextTest < StaminaTest

      def context
        Engine.execute <<-EOF
          a = 1
          b = 2 * a
        EOF
      end

      def test_to_h
        assert_equal({:a => 1, :b => 2, :main => 2}, context.to_h)
      end

      def test_to_a
        assert_equal([[:main, 2],[:a, 1], [:b, 2]], context.to_a)
      end

    end # class ContextTest
  end # class Engine
end # module Stamina
