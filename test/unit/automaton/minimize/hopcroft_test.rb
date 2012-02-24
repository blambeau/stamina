require File.expand_path("../minimize_test", __FILE__)
module Stamina
  class Automaton
    module Minimize
      class HopcroftTest < MinimizeTest

        def algo
          Hopcroft
        end

      end # class HopcroftTest
    end # module Minimize
  end # class Automaton
end # module Stamina