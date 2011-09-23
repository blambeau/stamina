require 'stamina_test'
module Stamina
  module Dsl
    class InductionTest < StaminaTest
      include Stamina::Dsl
    
      def test_sample
        expected = (Sample.new << "+ a")
        assert_equal expected, sample(expected)
        assert_equal expected, sample("+ a")
      end

      def test_rpni
        sample   = sample('+ a')
        expected = regular("a*")
        assert rpni(sample) <=> expected
      end

      def test_blue_fringe
        sample   = sample('+ a')
        expected = regular("a*")
        assert blue_fringe(sample) <=> expected
      end

    end
  end
end
