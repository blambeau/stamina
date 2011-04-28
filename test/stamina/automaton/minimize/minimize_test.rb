require 'test/unit'
require 'stamina/stamina_test'
module Stamina
  class Automaton
    module Minimize
      class MinimizeTest < StaminaTest

        def assert_equivalent(expected, dfa)
          assert expected.complete.equivalent?(dfa.complete)
        end

        # To be overriden
        def algo 
          nil
        end

        def test_on_unknown_1
          return unless algo
          dfa = load_adl_automaton("unknown_1.adl", __FILE__)
          min = load_adl_automaton("unknown_1.min.adl", __FILE__)
          assert_equivalent(algo.execute(dfa), min)
        end

        # From slide 10 in http://www.clear.rice.edu/comp412/Lectures/L07DFAMin-1up.pdf
        def test_on_rice_edu_10
          return unless algo
          dfa = load_adl_automaton("rice_edu_10.adl", __FILE__)
          min = load_adl_automaton("rice_edu_10.min.adl", __FILE__)
          assert_equivalent(algo.execute(dfa), min)
        end

        # From slide 13 in http://www.clear.rice.edu/comp412/Lectures/L07DFAMin-1up.pdf
        def test_on_rice_edu_13
          return unless algo
          dfa = load_adl_automaton("rice_edu_13.adl", __FILE__)
          min = load_adl_automaton("rice_edu_13.min.adl", __FILE__)
          assert_equivalent(algo.execute(dfa), min)
        end

        def test_it_has_no_effect_on_already_minimal
          return unless algo
          dfa = load_adl_automaton("rice_edu_13.min.adl", __FILE__)
          min = algo.execute(dfa)
          assert_equal dfa.complete.state_count, min.complete.state_count
          assert_equivalent(min, dfa)
        end

      end # class MinimizeTest
    end # module Minimize
  end # class Automaton
end # module Stamina

