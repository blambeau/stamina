require 'stamina_test'
module Stamina
  class RegLang
    class CanonicalInfoTest < StaminaTest

      def test_short_prefix_on_state
        info = CanonicalInfo.new(ab_star)
        assert_equal [], info.short_prefix(info.cdfa.ith_state(0))
        assert_equal ["a"], info.short_prefix(info.cdfa.ith_state(1))
      end

      def test_short_prefix_on_edge
        info = CanonicalInfo.new(ab_star)
        assert_equal ["a"], info.short_prefix(info.cdfa.ith_edge(0))
        assert_equal ["a", "b"], info.short_prefix(info.cdfa.ith_edge(1))
      end

      def test_positive_suffix
        dfa = Automaton.new do
          add_state :initial => true,  :accepting => false
          add_state :initial => false, :accepting => false
          add_state :initial => false, :accepting => true
          connect 0, 1, "a"
          connect 1, 0, "b"
          connect 1, 2, "c"
        end
        info = CanonicalInfo.new(dfa)
        assert_equal ["a", "c"], info.positive_suffix(dfa.ith_state(0))
        assert_equal ["c"], info.positive_suffix(dfa.ith_state(1))
        assert_equal [], info.positive_suffix(dfa.ith_state(2))
      end

      def test_positive_suffix_on_dum
        info = CanonicalInfo.new(dfa = Automaton::DUM)
        assert_equal nil, info.positive_suffix(dfa.ith_state(0))
      end

      def test_positive_suffix_on_dee
        info = CanonicalInfo.new(dfa = Automaton::DEE)
        assert_equal [], info.positive_suffix(dfa.ith_state(0))
      end

      def test_negative_suffix
        dfa = Automaton.new do
          add_state :initial => true,  :accepting => false
          add_state :initial => false, :accepting => true
          add_state :initial => false, :accepting => true
          add_state :initial => false, :accepting => true
          connect 0, 1, "a"
          connect 1, 0, "b"
          connect 1, 2, "c"
          connect 2, 1, "a"
          connect 2, 3, "b"
        end
        info = CanonicalInfo.new(dfa)
        assert_equal [], info.negative_suffix(dfa.ith_state(0))
        assert_equal ["b"], info.negative_suffix(dfa.ith_state(1))
        assert_equal ["a", "b"], info.negative_suffix(dfa.ith_state(2))
        assert_equal ["a"], info.negative_suffix(dfa.ith_state(3))
      end

      def test_negative_suffix_on_dum
        info = CanonicalInfo.new(dfa = Automaton::DUM)
        assert_equal [], info.negative_suffix(dfa.ith_state(0))
      end

      def test_find_negative_suffix_on_dee
        info = CanonicalInfo.new(dfa = Automaton::DEE)
        assert_equal nil, info.negative_suffix(dfa.ith_state(0))
      end

      def test_short_prefixes_on_ab_star
        expected = Sample.parse <<-ADL
          +
          - a
        ADL
        info = CanonicalInfo.new(ab_star)
        assert_equal expected, info.short_prefixes
      end

      def test_kernel_on_ab_star
        expected = Sample.parse <<-ADL
          +
          - a
          + a b
        ADL
        info = CanonicalInfo.new(ab_star)
        assert_equal expected, info.kernel
      end

    end # class CanonicalInfoTest
  end # class RegLang
end # module Stamina
