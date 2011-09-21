require 'test/unit'
require 'stamina/stamina_test'
module Stamina
  class Automaton
    class ComplementTest < StaminaTest

      def test_complete
        dfa = ab_star
        assert dfa.accepts?("?")
        assert !dfa.accepts?("? a")
        assert dfa.accepts?("? a b")

        comp = dfa.complement
        assert_equal 3, comp.state_count
        assert_equal 2, dfa.state_count
        assert !comp.accepts?("?")
        assert comp.accepts?("? a")
        assert !comp.accepts?("? a b")

        expected = Automaton.new(true) do |fa|
          fa.alphabet = ["a", "b"]
          fa.add_state(:initial => true,  :accepting => false)
          fa.add_state(:initial => false, :accepting => true)
          fa.add_state(:initial => false, :accepting => true)
          fa.connect(0,1,'a')
          fa.connect(0,2,'b')
          fa.connect(1,0,'b')
          fa.connect(1,2,'a')
          fa.connect(2,2,'a')
          fa.connect(2,2,'b')
        end
        assert dfa.complement.equivalent?(expected)
      end

    end
  end
end
