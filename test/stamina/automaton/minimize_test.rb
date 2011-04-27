require 'test/unit'
require 'stamina/stamina_test'
module Stamina
  class Automaton
    class MinimizeTest < StaminaTest
      
      def test_on_small_dfa
        assert @small_dfa.minimal?
        result = @small_dfa.minimize
        assert result.minimal?
        assert result.complete <=> @small_dfa.complete
      end
      
      def test_on_example_1
        dfa = Stamina::ADL.parse_automaton <<-EOF
          5 9
          0 true false
          1 false false
          2 false false
          3 false true
          4 false true
          0 1 a
          0 1 b
          0 1 c
          0 2 d
          0 2 f
          1 3 f
          1 3 g
          2 4 f
          2 4 g
        EOF
        dfa.complete!
        assert_equal false, dfa.minimal?
        expected = Stamina::ADL.parse_automaton <<-EOF
          3 7
          0 true false
          1 false false
          2 false true
          0 1 a
          0 1 b
          0 1 c
          0 1 d
          0 1 f
          1 2 f
          1 2 g
        EOF
        expected.complete!
        result = dfa.minimize
        assert result.minimal?
        assert expected <=> result
        assert expected <=> dfa.minimize
      end

#      def test_it_removes_sinks
#        dfa = Stamina::ADL.parse_automaton <<-EOF
#          7 12
#          0 true false
#          1 false false
#          2 false false
#          3 false true
#          4 false true
#          5 false false
#          6 false false
#          0 1 a
#          0 1 b
#          0 1 c
#          0 2 d
#          0 2 f
#          1 3 f
#          1 3 g
#          2 4 f
#          2 4 g
#          1 5 a
#          5 6 a
#          6 5 b
#        EOF
#        assert_equal false, dfa.minimal?
#        expected = Stamina::ADL.parse_automaton <<-EOF
#          3 7
#          0 true false
#          1 false false
#          2 false true
#          0 1 a
#          0 1 b
#          0 1 c
#          0 1 d
#          0 1 f
#          1 2 f
#          1 2 g
#        EOF
#        result = Minimizer.execute(dfa)
#        assert result.minimal?
#        assert expected <=> result
#        assert expected <=> dfa.minimize
#      end

      def test_minimizing_has_no_effect_on_a_minimal
        expected = Stamina::ADL.parse_automaton <<-EOF
          3 7
          0 true false
          1 false false
          2 false true
          0 1 a
          0 1 b
          0 1 c
          0 1 d
          0 1 f
          1 2 f
          1 2 g
        EOF
        expected.complete!
        assert expected.minimal?
        assert expected <=> expected.minimize
      end

      def test_minimizing_on_public_example
        source = Stamina::ADL.parse_automaton <<-EOF
          3 5
          0 true true
          1 false false
          2 false true
          0 1 a
          1 1 a
          1 2 b
          2 2 b
          2 0 a
        EOF
        source.complete!
        assert_equal true, source.minimal?
      end
      
    end # class MinimizeTest
  end # class Automaton
end # module Stamina

