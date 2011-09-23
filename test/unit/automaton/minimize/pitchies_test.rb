require File.expand_path("../minimize_test", __FILE__)
module Stamina
  class Automaton
    module Minimize
      class PitchiesTest < MinimizeTest

        def algo
          Pitchies
        end

      end # class PitchiesTest
    end # module Minimize
  end # class Automaton
end # module Stamina

