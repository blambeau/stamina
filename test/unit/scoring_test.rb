require 'stamina_test'
module Stamina
  class ScoringTest < StaminaTest

    def assert_almost_equal(x, y)
      assert (x.to_f - y.to_f).abs <= 0.0001
    end

    def test_scoring_on_exact
      learned, reference = "11010", "11010"
      scoring = Scoring.scoring(learned, reference)

      # It looks like a Scoring object
      assert scoring.respond_to?(:false_positive)
      assert scoring.respond_to?(:recall)

      # four measures are ok
      assert_equal 3, scoring.true_positive
      assert_equal 2, scoring.true_negative
      assert_equal 0, scoring.false_positive
      assert_equal 0, scoring.false_negative

      # precision and recall are ok
      assert_equal (3.0 / (3.0 + 0.0)), scoring.precision
      assert_equal (3.0 / (3.0 + 0.0)), scoring.recall

      # sensitivity and specificity are ok
      assert_equal (3.0 / (3.0 + 0.0)), scoring.sensitivity
      assert_equal (3.0 / (3.0 + 0.0)), scoring.specificity

      #
      assert_equal 1.0, scoring.accuracy
      assert_equal 1.0, scoring.bcr
      assert_equal 1.0, scoring.f_measure
      assert_equal 1.0, scoring.hbcr
    end

    def test_on_wikipedia_example
      hash = {
        :true_positive  => 2,
        :false_positive => 18,
        :true_negative  => 182,
        :false_negative => 1
      }
      hash.extend(Scoring)
      assert_equal (2.0 / (2 + 18)), hash.positive_predictive_value
      assert_equal (182.0 / (1 + 182)), hash.negative_predictive_value
      assert_equal (2.0 / (2 + 1)), hash.sensitivity
      assert_equal (182.0 / (18 + 182)), hash.specificity
      assert_equal (18.0 / (18 + 182)), hash.false_positive_rate
      assert_equal (1.0 / (2 + 1)), hash.false_negative_rate
      #
      assert_almost_equal (1.0 - hash.specificity), hash.false_positive_rate
      assert_almost_equal (1.0 - hash.sensitivity), hash.false_negative_rate
      assert_almost_equal hash.sensitivity / (1.0 - hash.specificity), hash.positive_likelihood
      assert_almost_equal (1.0 - hash.sensitivity) / hash.specificity, hash.negative_likelihood
    end

  end # class ScoringTest
end # module Stamina