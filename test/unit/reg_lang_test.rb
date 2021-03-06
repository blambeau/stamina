require 'stamina_test'
module Stamina
  class RegLangTest < StaminaTest

    def test_coerce
      assert RegLang.coerce("(a b)*").is_a?(RegLang)
      assert RegLang.coerce(ab_star).is_a?(RegLang)
      assert RegLang.coerce(RegLang.coerce(ab_star)).is_a?(RegLang)
      assert RegLang.coerce(Sample.new).is_a?(RegLang)
    end

    def test_sigma_star
      assert RegLang.sigma_star('a'..'b') <=> RegLang.parse("(a | b)*")
    end

    def test_equality
      ab_plus   = RegLang.parse("(a b)+")
      ab_plus_2 = RegLang.parse("a b (a b)*")
      assert ab_plus.eql?(ab_plus_2)
      assert ab_plus <=> ab_plus_2
    end

    def test_parse
      ab_star = RegLang.parse("(a b)*")
      assert ab_star.is_a?(RegLang)
    end

    def test_include
      ab_star = RegLang.parse("(a b)*")
      assert  ab_star.include?("?")
      assert  ab_star.include?("? a b")
      assert  ab_star.include?("? a b a b")
      assert !ab_star.include?("? a")
    end

    def test_prefix_closed
      ab_star_pc = RegLang.parse("(a b)*").prefix_closed
      expected   = RegLang.parse("(a b)* | a (b a)*")
      assert ab_star_pc.eql?(expected)
    end

    def test_complement
      ab_star_c = RegLang.parse("(a b)*").complement
      assert ab_star_c.include?("? b")
      assert ab_star_c.include?("? a a")
      assert !ab_star_c.include?("? a b")
    end

    def test_complement_2
      ab_star_c = RegLang.parse("(a b)*")**-1
      assert ab_star_c.include?("? b")
      assert ab_star_c.include?("? a a")
      assert !ab_star_c.include?("? a b")
    end

    def test_union_1
      ab_star = RegLang.parse("(a b)*")
      ba_star = RegLang.parse("(b a)*")
      unioned = ab_star + ba_star
      expected = RegLang.parse("(a b)* | (b a)*")
      assert expected.eql?(unioned)
    end

    def test_union_2
      ab_star = RegLang.parse("(a b)*")
      ba_star = RegLang.parse("(b a)*")
      unioned = ab_star | ba_star
      expected = RegLang.parse("(a b)* | (b a)*")
      assert expected.eql?(unioned)
    end

    def test_intersection_1
      x = RegLang.parse("(a b)*")
      y = RegLang.parse("(a | b)*")
      expected = RegLang.parse("(a b)*")
      assert expected.eql?(x & y)
    end

    def test_difference_on_same
      x = RegLang.parse("(a b)*")
      assert (x - x) <=> RegLang::EMPTY
    end

    def test_empty?
      x = RegLang.parse("(a b)*")
      assert !x.empty?
      assert RegLang::EMPTY.empty?
      assert (x - x).empty?
    end

  end # class RegLangTest
end # module Stamina