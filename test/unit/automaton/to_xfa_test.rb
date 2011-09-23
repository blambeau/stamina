require 'stamina/adl'
require 'stamina_test'
module Stamina
  class Automaton
    class ToXFaTest < StaminaTest

      def nfa
        @nfa ||= Automaton.new do 
          add_state(:initial => true, :accepting => false)
          add_n_states(4)
          add_n_states(2, :accepting => true)
          connect(0,1,nil)
          connect(0,2,nil)
          connect(1,3,"a")
          connect(2,4,"a")
          connect(3,5,"b")
          connect(4,6,"c")
        end
      end

      def test_to_fa
        assert_equal nfa, nfa.to_fa
        assert !nfa.deterministic?
        assert_equal 7, nfa.state_count
      end

      def test_to_dfa
        dfa = nfa.to_dfa
        assert dfa.deterministic?
        assert !dfa.minimal?
        assert_equal 4, dfa.state_count
      end

      def test_to_cdfa
        dfa = nfa.to_cdfa
        assert dfa.deterministic?
        assert dfa.minimal?
        assert_equal 3, dfa.state_count
      end

    end
  end
end
