require 'stamina_test'
module Stamina
  module Dsl
    class AutomataTest < StaminaTest
      include Stamina::Dsl

      def test_automaton
        assert ab_star.equivalent?(automaton(ab_star))
        code = <<-EOF
          2 2
          0 true true
          1 false false
          0 1 a
          1 0 b
        EOF
        assert ab_star.equivalent?(automaton(code))
      end

    end
  end
end