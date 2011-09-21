module Stamina
  class RegLangTest < Test::Unit::TestCase

    def test_parse
      ab_star = RegLang.parse("(a b)*")
      assert ab_star.is_a?(RegLang)
      assert  ab_star.include?("? a b")
      assert  ab_star.include?("?")
      assert  ab_star.include?("? a b a b")
      assert !ab_star.include?("? a")
    end

    def test_prefix_closed
      ab_star_pc = RegLang.parse("(a b)*").prefix_closed
      assert ab_star_pc.is_a?(RegLang)
      assert  ab_star_pc.include?("? a b")
      assert  ab_star_pc.include?("?")
      assert  ab_star_pc.include?("? a b a b")
      assert  ab_star_pc.include?("? a")
    end

  end # class RegLangTest
end # module Stamina
