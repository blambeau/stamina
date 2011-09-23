require 'stamina_test'
module Stamina
  class Sample
    # Tests Classify module, as installed on Sample and InputString classes.
    class ClassifyTest < StaminaTest

      # Tests Classify#correctly_classified_by? is correct on valid sample against
      # small_dfa example
      def test_valid_sample_correctly_classified_by_small_dfa
        assert_equal(true, Sample.new.correctly_classified_by?(@small_dfa))
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
        assert_equal(true, sample.correctly_classified_by?(@small_dfa))
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
        assert_equal(false, sample.correctly_classified_by?(@small_dfa))

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
        assert_equal(false, sample.correctly_classified_by?(@small_dfa))

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
        assert_equal(false, sample.correctly_classified_by?(@small_dfa))
      end
  
      # Tests Classify#correctly_classified_by? is correct on valid sample against
      # small_nfa example
      def test_valid_sample_correctly_classified_by_small_nfa
        assert_equal(true, Sample.new.correctly_classified_by?(@small_nfa))
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
        assert_equal(true, sample.correctly_classified_by?(@small_nfa))
      end

      # Tests Classify#correctly_classified_by? is correct on invalid sample against
      # small_nfa example
      def test_invalid_sample_correctly_classified_by_small_nfa
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
        assert_equal(false, sample.correctly_classified_by?(@small_nfa))
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
        assert_equal(false, sample.correctly_classified_by?(@small_nfa))
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
        assert_equal(false, sample.correctly_classified_by?(@small_nfa))
      end

    end # class ClassifyTest
  end # class Sample
end # module Stamina
