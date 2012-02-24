require 'stamina_test'
module Stamina
  class AutomatonDepthRegressionTest < StaminaTest

    def test_it_does_raise_an_error
      dfa = ADL.parse_automaton_file File.expand_path('../depth_fail.adl', __FILE__)
      dfa.each_edge do |edge|
        edge[:symbol] = nil if edge[:symbol] == "nil"
      end
      dfa.to_dot
    end

  end
end