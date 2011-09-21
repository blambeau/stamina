module Stamina
  class RegLangTest < Test::Unit::TestCase

    def test_parse
      ab_star = RegLang.parse("(a b)*")
      assert ab_star.is_a?(RegLang)
      assert  ab_star.include?("?")
      assert  ab_star.include?("? a b")
      assert  ab_star.include?("? a b a b")
      assert !ab_star.include?("? a")
    end

    def test_prefix_closed
      ab_star_pc = RegLang.parse("(a b)*").prefix_closed
      assert ab_star_pc.is_a?(RegLang)
      assert ab_star_pc.include?("? a b")
      assert ab_star_pc.include?("?")
      assert ab_star_pc.include?("? a b a b")
      assert ab_star_pc.include?("? a")
    end

    def test_complement
      ab_star_c = RegLang.parse("(a b)*").complement
      puts ab_star_c.to_fa.to_dot
      assert ab_star_c.is_a?(RegLang)
      assert !ab_star_c.include?("?")
      assert !ab_star_c.include?("? a b")
      assert !ab_star_c.include?("? a b a b")
      assert ab_star_c.include?("? a")
      assert ab_star_c.include?("? a b a")
    end

    def test_union
      ab_star = RegLang.parse("(a b)*")
      ba_star = RegLang.parse("(b a)*")
      unioned = ab_star + ba_star
      assert unioned.is_a?(RegLang)
      assert unioned.include?("?")
      assert unioned.include?("? a b")
      assert unioned.include?("? b a")
    end

  end # class RegLangTest
end # module Stamina
