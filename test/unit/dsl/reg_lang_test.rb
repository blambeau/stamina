require 'stamina_test'
module Stamina
  module Dsl
    class RegLangTest < StaminaTest
      include Stamina::Dsl

      def test_regular
        expected = Stamina::RegLang.parse("(a b)*")
        assert regular("(a b)*") <=> expected
        assert regular(ab_star) <=> expected
        assert regular(regular(ab_star)) <=> expected
        assert regular(Sample.new).is_a?(Stamina::RegLang)
      end

      def test_sigma_star
        expected = Stamina::RegLang.parse("(a | b)*")
        assert sigma_star('a'..'b') <=> expected
      end

      def test_prefix_closed
        expected = Stamina::RegLang.parse("a b").prefix_closed
        assert prefix_closed("a b") <=> expected
      end

      def test_hide
        ab_star = regular("(a b)*")
        a_star = regular("a*")
        assert hide(ab_star, ["b"]) <=> a_star
      end

      def test_project
        ab_star = regular("(a b)*")
        a_star = regular("a*")
        assert project(ab_star, ["a"]) <=> a_star
      end

    end
  end
end