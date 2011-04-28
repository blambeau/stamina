require 'stamina/stamina_test'
require 'stamina/abbadingo'
module Stamina
  module Abbadingo
    class RandomSampleTest < StaminaTest

      def test_string_count
        rs = RandomSample.new(64)
        assert_equal 15, rs.max_string_length
        assert_equal 16*(64 ** 2) - 1, rs.string_count
      end

      def test_length_for
        rs = RandomSample.new(64)
        assert_equal 0, rs.length_for(1) 
        assert_equal 1, rs.length_for(2)
        assert_equal 1, rs.length_for(3)
        assert_equal 2, rs.length_for(4)
        assert_equal 2, rs.length_for(5)
        assert_equal 2, rs.length_for(6)
        assert_equal 2, rs.length_for(7)
        assert_equal 3, rs.length_for(8)
      end

      def test_it_looks_ok_with_default_options
        sample = RandomSample.new(64)
        lengths = Hash.new{|h,k| h[k] = 0}
        max = 2*(sample.dfa_size ** 2)
        max.times{ lengths[sample.generate_string.length] += 1 }
        assert (lengths.keys - (0..sample.max_string_length).to_a).empty?
        prop = (0..sample.max_string_length).collect{|i| lengths[i].to_f/max}
        assert prop[-1] >= 0.4 and prop[-1] <= 0.6
        assert prop[-2] >= 0.2 and prop[-1] <= 0.3
        assert prop[-3] >= 0.1 and prop[-1] <= 0.15
      end

    end # class RandomDFATest
  end # module Abbadingo
end # module Stamina
