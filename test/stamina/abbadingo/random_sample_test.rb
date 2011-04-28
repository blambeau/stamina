require 'stamina/stamina_test'
require 'stamina/abbadingo'
module Stamina
  module Abbadingo
    class RandomSampleTest < StaminaTest

      def test_length_for
        rs = RandomSample::StringEnumerator.new
        assert_equal 0, rs.length_for(1) 
        assert_equal 1, rs.length_for(2)
        assert_equal 1, rs.length_for(3)
        assert_equal 2, rs.length_for(4)
        assert_equal 2, rs.length_for(5)
        assert_equal 2, rs.length_for(6)
        assert_equal 2, rs.length_for(7)
        assert_equal 3, rs.length_for(8)
      end

      def test_string_for
        rs = RandomSample::StringEnumerator.new
        assert_equal [], rs.string_for(1)
        assert_equal ["0"], rs.string_for(2)
        assert_equal ["1"], rs.string_for(3)
        assert_equal ["0", "0"], rs.string_for(4)
        assert_equal ["1", "0"], rs.string_for(5)
        assert_equal ["0", "1"], rs.string_for(6)
        assert_equal ["1", "1"], rs.string_for(7)
      end

      def test_string_for_generates_all_diff
        rs = RandomSample::StringEnumerator.new
        h = {}
        (1..100).each{|i| h[rs.string_for(i)] = true}
        assert_equal 100, h.size
      end

      def test_string_for_respects_distribution
        rs = RandomSample::StringEnumerator.new
        lengths = Hash.new{|h,k| h[k] = 0}
        (1..127).each{|i| lengths[rs.string_for(i).size] += 1}
        assert_equal [0, 1, 2, 3, 4, 5, 6], lengths.keys.sort
        prop = (0..6).collect{|i| lengths[i].to_f/128}
        assert_equal [0.0078125, 0.015625, 0.03125, 0.0625, 0.125, 0.25, 0.5], prop
      end

      def test_enumerator
        enum = RandomSample::StringEnumerator.new(10)
        lengths = Hash.new{|h,k| h[k] = 0}
        20000.times{lengths[enum.one.size] += 1}
        assert (lengths.keys.sort - (0..10).to_a).empty?
        prop = (0..10).collect{|i| lengths[i].to_f/20000}
        assert((prop[-1] >= 0.45) && (prop[-1] <= 0.55))
        assert((prop[-2] >= 0.2) && (prop[-2] <= 0.3))
        assert((prop[-3] >= 0.1) && (prop[-3] <= 0.15))
      end

      def test_execute
        dfa = RandomDFA.new(32).execute
        test, training = RandomSample.execute(dfa)
#        puts "#{test.size} #{test.positive_count} #{test.negative_count}" 
#        puts "#{training.size} #{training.positive_count} #{training.negative_count}" 
        assert dfa.correctly_classify?(training)
        assert dfa.correctly_classify?(test)
      end

    end # class RandomDFATest
  end # module Abbadingo
end # module Stamina
