require 'test/unit'
require 'stamina/stamina_test'
module Stamina
  class Automaton
    # Tests Walking module on Automaton class
    class WalkingTestDfaDelta < StaminaTest

      DFA = Stamina::ADL::parse_automaton <<-EOF
        2 3
        0 true false
        1 false true
        0 1 a
        1 0 b
        1 1 a
      EOF
      S0 = DFA.ith_state(0)
      S1 = DFA.ith_state(1)

      def test_with_single_state_as_from
        assert_equal S1, DFA.dfa_delta(S0, 'a')
        assert_equal S1, DFA.dfa_delta(0, 'a')
        assert_equal S0, DFA.dfa_delta(1, 'b')
      end

      def test_with_single_array_as_from
        assert_equal [S1], DFA.dfa_delta([S0], 'a')
        assert_equal [S1], DFA.dfa_delta([0], 'a')
        assert_equal [S0], DFA.dfa_delta([1], 'b')
      end

      def test_with_multiple_array_as_from
        assert_equal [S1], DFA.dfa_delta([S0, S1], 'a')
        assert_equal [S1], DFA.dfa_delta([0, 1], 'a')
        assert_equal [S0], DFA.dfa_delta([0, 1], 'b')
      end

    end # class WalkingTestDfaDelta
  end # class Automaton
end # module Stamina
