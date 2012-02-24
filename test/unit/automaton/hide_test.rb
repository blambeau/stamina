require 'stamina_test'
module Stamina
  class Automaton
    class HideTest < StaminaTest

      def test_hide
        hidden = ab_star.hide(["a"])
        assert_equal 2, ab_star.state_count
        assert hidden.to_cdfa <=> b_star.to_cdfa
        assert_equal ["b"], hidden.alphabet.to_a
      end

      def test_keep
        hidden = ab_star.keep(["a"])
        assert_equal 2, ab_star.state_count
        assert hidden.to_cdfa <=> a_star.to_cdfa
        assert_equal ["a"], hidden.alphabet.to_a
      end

      def test_hide!
        hidden = ab_star.dup
        hidden.hide!(["a"])
        assert hidden.to_cdfa <=> b_star.to_cdfa
        assert_equal ["b"], hidden.alphabet.to_a
      end

      def test_keep!
        hidden = ab_star.dup
        hidden.keep!(["a"])
        assert hidden.to_cdfa <=> a_star.to_cdfa
        assert_equal ["a"], hidden.alphabet.to_a
      end

    end # class HideTest
  end # class Automaton
end # module Stamina