require 'stamina_test'
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
  
      def test_scoring_on_valid_sample
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
        measures = @small_dfa.scoring(sample)
        assert_equal(sample.positive_count, measures.true_positive)
        assert_equal(0, measures.false_positive)
        assert_equal(sample.negative_count, measures.true_negative)
        assert_equal(0, measures.false_negative)
        assert_equal(1.0, measures.precision)  
        assert_equal(1.0, measures.recall)  
        assert_equal(1.0, measures.sensitivity)  
        assert_equal(1.0, measures.specificity)  
        assert_equal(1.0, measures.accuracy)
      end

      def test_scoring_on_invalid_sample
        sample = ADL::parse_sample <<-SAMPLE
          +
          - b
          - b c
          + b c a
          + b c a c
          + b c a c a
          + b c a a
          - b c a b
          - b c a b c a c b
          + z
          + b z
        SAMPLE
        measures = @small_dfa.scoring(sample)
        assert_equal(0.0, measures.true_positive)
        assert_equal(sample.negative_count, measures.false_positive)
        assert_equal(0.0, measures.true_negative)
        assert_equal(sample.positive_count, measures.false_negative)
        assert_equal(0.0, measures.precision)  
        assert_equal(0.0, measures.recall)  
        assert_equal(0.0, measures.sensitivity)  
        assert_equal(0.0, measures.specificity)  
        assert_equal(0.0, measures.accuracy)
      end

      def test_scoring_with_positive_only
        sample = ADL::parse_sample <<-SAMPLE
          +
          + b
          + b c
          + b c a
          + b c a c
          + b c a c a
          + b c a a
          + b c a b
          + b c a b c a c b
          + z
          + b z
        SAMPLE
        measures = @small_dfa.scoring(sample)
        assert_equal(4.0, measures.true_positive)
        assert_equal(sample.size-sample.positive_count, measures.false_positive)
        assert_equal(0, measures.true_negative)
        assert_equal(sample.size-4.0, measures.false_negative)
        assert_equal(1.0, measures.precision)  
        assert_equal(4.0/sample.size, measures.recall)  
        assert_equal(4.0/sample.size, measures.sensitivity)  
        #assert_equal(0.0/0.0, measures.specificity)  
        assert_equal(4.0/sample.size, measures.accuracy)
      end
      
      def test_scoring_with_negative_only
        sample = ADL::parse_sample <<-SAMPLE
          -
          - b
          - b c
          - b c a
          - b c a c
          - b c a c a
          - b c a a
          - b c a b
          - b c a b c a c b
          - z
          - b z
        SAMPLE
        measures = @small_dfa.scoring(sample)
        assert_equal(0.0, measures.true_positive)
        assert_equal(4.0, measures.false_positive)
        assert_equal(sample.size-4.0, measures.true_negative)
        assert_equal(0.0, measures.false_negative)
        assert_equal(0.0, measures.precision)  
        #assert_equal(0.0, measures.recall)  
        #assert_equal(0.0, measures.sensitivity)  
        assert_equal((sample.size-4.0)/sample.size, measures.specificity)  
        assert_equal((sample.size-4.0)/sample.size, measures.accuracy)
      end

    end # class ClassifierTest
  end # class Automaton
end # module Stamina
