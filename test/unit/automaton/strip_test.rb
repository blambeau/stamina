require 'test/unit'
require 'stamina/adl'
require 'stamina_test'
module Stamina
  class Automaton
    class StripTest < StaminaTest

      def test_on_all_reachable
        assert_equivalent @small_dfa, @small_dfa.strip
      end

      def test_with_unreachable_states
        dfa = Stamina::ADL.parse_automaton <<-EOF
          3 3
          0 true false
          1 false true
          2 false false
          0 1 a
          1 0 b
          2 1 a
        EOF
        expected = Stamina::ADL.parse_automaton <<-EOF
          2 2
          0 true false
          1 false true
          0 1 a
          1 0 b
        EOF
        assert_not_equivalent(expected, dfa)
        assert_equivalent(expected, dfa.strip)
      end

    end # class StripTest
  end # class Automaton
end # module Stamina

