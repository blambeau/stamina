require 'test/unit'
require 'stamina/stamina_test'
module Stamina
  class Automaton
    class EquivalenceTest < StaminaTest

      def test_equivalence_on_small_dfa
        assert_equal true, @small_dfa <=> @small_dfa
      end
      
      def test_equivalence_on_real_case
        dfa1 = Stamina::ADL.parse_automaton <<-EOF
          3 5
          0 true false
          1 false false
          2 false true
          0 1 a
          1 1 a
          1 2 b
          2 2 b
          0 2 b
        EOF
        dfa2 = Stamina::ADL.parse_automaton <<-EOF
          3 5
          0 false true
          1 true false
          2 false false
          0 0 b
          1 2 a
          1 0 b
          2 2 a
          2 0 b
        EOF
        dfa3 = Stamina::ADL.parse_automaton <<-EOF
          3 5
          0 false false
          1 false true
          2 true false
          0 0 a
          0 1 b
          1 1 b
          2 0 a
          2 1 b
        EOF
        assert_equal true, dfa1 <=> dfa2
        assert_equal true, dfa2 <=> dfa1
        assert_equal true, dfa1 <=> dfa3
        assert_equal true, dfa3 <=> dfa1
        assert_equal true, dfa2 <=> dfa3
        assert_equal true, dfa3 <=> dfa2
      end
      
      def test_equivalence_does_not_change_the_automata
        dfa1 = Stamina::ADL.parse_automaton <<-EOF
          1 1
          0 true true
          0 0 a
        EOF
        assert_not_nil dfa1.initial_state
        assert_equal true, dfa1 <=> dfa1
        assert_not_nil dfa1.initial_state
      end
      
      def test_non_equivalent_dfa_are_recognized_1
        dfa1 = Stamina::ADL.parse_automaton <<-EOF
          3 5
          0 true false
          1 false false
          2 false true
          0 1 a
          1 1 a
          1 2 b
          2 2 b
          0 2 b
        EOF
        assert_equal false, @small_dfa <=> dfa1
        assert_equal false, dfa1 <=> @small_dfa
      end
      
      def test_non_equivalent_dfa_are_recognized_2
        dfa1 = Stamina::ADL.parse_automaton <<-EOF
          5 4
          0 true false
          1 false false
          2 false false
          3 false false
          4 false false
          0 1 a
          1 2 a
          2 3 a
          3 4 a
        EOF
        dfa2 = Stamina::ADL.parse_automaton <<-EOF
          1 1
          0 true true
          0 0 a
        EOF
        assert_equal false, dfa2 <=> dfa1
        assert_not_nil dfa1.initial_state
        assert_not_nil dfa2.initial_state
        assert_equal false, dfa1 <=> dfa2
      end
      
      def test_equivalence_takes_care_of_state_flags
        dfa1 = Stamina::ADL.parse_automaton <<-EOF
          1 0
          0 true false
        EOF
        dfa2 = Stamina::ADL.parse_automaton <<-EOF
          1 0
          0 true true
        EOF
        assert_equal false, dfa1 <=> dfa2
        assert_equal false, dfa2 <=> dfa1
      end

    end # class EquivalenceTest
  end # class Automaton
end # module Stamina

