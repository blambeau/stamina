module Stamina
  class RegLang
    class KernelTest < Test::Unit::TestCase

      def test_on_ab_star
        ab_star = Stamina.regular("(a b)*")
        expected = Sample.parse <<-ADL
          +
          - a
          + a b
        ADL
        assert_equal expected, ab_star.kernel
      end

    end # class KernelTest
  end # class RegLang
end # module Stamina
