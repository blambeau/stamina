require 'test/unit'
require 'stamina/adl'
require 'stamina/stamina_test'
module Stamina
  class Automaton
    # Tests Classifier module, as to be installed on Automaton.
    class ClassifierTest < StaminaTest
  
      # Tests Classify#correctly_classified_by? is correct on valid sample against
      # small_dfa example
      def test_valid_sample_correctly_satified_by_small_dfa
        assert_equal(true, @small_dfa.correctly_classify?(Sample.new))
        sample = ADL::parse_sample <<-SAMPLE
          -
          + b
          + b c
          - b c a
          - b c a c
          - b c a c a
          - b c a a
          + b c a b
          + b c a b c a c b
          - z
          - b z
        SAMPLE
        assert_equal '01100001100', sample.signature
        assert_equal(true, @small_dfa.correctly_classify?(sample))
        assert_equal sample.signature, @small_dfa.signature(sample)
      end

      # Tests Classify#correctly_classified_by? is correct on invalid sample against
      # small_dfa example
      def test_invalid_sample_correctly_classified_by_small_dfa
        sample = ADL::parse_sample <<-SAMPLE
          -
          + b
          + b c
          - b c a
          # this one is reversed
          + b c a c
          - b c a c a
          - b c a a
          + b c a b
          + b c a b c a c b
          - z
          - b z
        SAMPLE
        assert_equal(false, @small_dfa.correctly_classify?(sample))
        assert_equal '01100001100', @small_dfa.signature(sample)

        sample = ADL::parse_sample <<-SAMPLE
          -
          + b
          + b c
          - b c a
          - b c a c
          - b c a c a
          - b c a a
          + b c a b
          + b c a b c a c b
          # this one is changed
          + z
          - b z
        SAMPLE
        assert_equal(false, @small_dfa.correctly_classify?(sample))
        assert_equal '01100001100', @small_dfa.signature(sample)

        sample = ADL::parse_sample <<-SAMPLE
          -
          + b
          + b c
          - b c a
          - b c a c
          - b c a c a
          - b c a a
          + b c a b
          # this one is changed
          - b c a b c a c b
          - z
          - b z
        SAMPLE
        assert_equal(false, @small_dfa.correctly_classify?(sample))
        assert_equal '01100001100', @small_dfa.signature(sample)
      end
    
      # Tests Classify#correctly_classify? is correct on valid sample against
      # small_nfa example
      def test_valid_sample_correctly_satified_by_small_nfa
        assert_equal(true, @small_nfa.correctly_classify?(Sample.new))
        sample = ADL::parse_sample <<-SAMPLE
          +
          + a
          - a a
          + a a b
          + a b
          + a b c a
          - a b c
          + a b b b b b b 
          - a z
          - z
        SAMPLE
        assert_equal(true, @small_nfa.correctly_classify?(sample))
        assert_equal sample.signature, @small_nfa.signature(sample)
      end
  
      # Tests Classify#correctly_classify? is correct on invalid sample against
      # small_nfa example
      def test_invalid_sample_correctly_satified_by_small_nfa
        sample = ADL::parse_sample <<-SAMPLE
          # this one is changed
          -
          + a
          - a a
          + a a b
          + a b
          + a b c a
          - a b c
          + a b b b b b b 
          - a z
          - z
        SAMPLE
        assert_equal(false, @small_nfa.correctly_classify?(sample))
        sample = ADL::parse_sample <<-SAMPLE
          +
          + a
          - a a
          + a a b
          # this one is changed
          - a b
          + a b c a
          - a b c
          + a b b b b b b 
          - a z
          - z
        SAMPLE
        assert_equal(false, @small_nfa.correctly_classify?(sample))
        sample = ADL::parse_sample <<-SAMPLE
          +
          + a
          # this one is changed
          + a a
          + a a b
          + a b
          + a b c a
          - a b c
          + a b b b b b b 
          - a z
          - z
        SAMPLE
        assert_equal(false, @small_nfa.correctly_classify?(sample))
      end
  
    end # class ClassifierTest
  end # class Automaton
end # module Stamina