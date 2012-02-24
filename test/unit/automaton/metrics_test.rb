require 'stamina_test'
require 'stamina/adl'
module Stamina
  class Automaton
    class MetricsTest < StaminaTest

      def test_alphabet_size
        assert_equal 3, @small_dfa.alphabet_size
      end

      def test_avg_degree
        assert_equal 6.to_f/4, @small_dfa.avg_degree
      end

      def test_avg_out_degree
        assert_equal 6.to_f/4, @small_dfa.avg_out_degree
      end

      def test_avg_in_degree
        assert_equal 6.to_f/4, @small_dfa.avg_in_degree
      end

      def test_accepting_ratio
        assert_equal 0.5, @small_dfa.accepting_ratio
      end

      def test_depth
        assert_equal 3, @small_dfa.depth
        assert_equal 2, @small_nfa.depth
      end

      def test_depth_on_empty
        a = Automaton.new{ add_state(:initial => true) }
        assert_equal 0, a.depth
      end

    end
  end
end