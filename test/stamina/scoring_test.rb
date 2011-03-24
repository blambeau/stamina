require 'test/unit'
require 'stamina/errors'
require 'stamina/stamina_test'
require 'stamina/scoring'
module Stamina
  class ScoringTest < StaminaTest

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

  end # class ScoringTest
end # module Stamina
