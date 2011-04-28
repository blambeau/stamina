require 'stamina/stamina_test'
require 'stamina/abbadingo'
module Stamina
  module Abbadingo
    class RandomDFATest < StaminaTest

      def test_it_looks_ok_with_default_options
        2.times do |i|
          dfa = RandomDFA.new.execute
          assert dfa.deterministic?
          assert dfa.minimal?
          assert dfa.complete?
          #puts dfa.state_count
        end
      end

    end # class RandomDFATest
  end # module Abbadingo
end # module Stamina
