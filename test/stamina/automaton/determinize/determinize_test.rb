require 'test/unit'
require 'stamina/stamina_test'
module Stamina
  class Automaton
    class DeterminizeTest < StaminaTest

      def test_on_deterministic
        determ = ab_star.determinize
        assert determ.complete <=> ab_star.complete
      end

      def test_on_nondeterministic
        nfa = Automaton.new do
          add_state(:initial => true,  :accepting => false)
          add_state(:initial => false, :accepting => false)
          add_state(:initial => false, :accepting => true)
          add_state(:initial => false, :accepting => true)
          connect(0,1,"a")
          connect(0,2,nil)
          connect(1,1,"b")
          connect(1,3,"b")
          connect(2,3,"a")
          connect(3,2,"a")
          connect(2,1,nil)
        end
        expected = Automaton.new do
          add_state(:initial => true, :accepting => true)
          add_state(:initial => false, :accepting => true)
          add_state(:initial => false, :accepting => true)
          add_state(:initial => false, :accepting => true)
          connect(0,1,"a")
          connect(0,1,"b")
          connect(1,1,"b")
          connect(1,2,"a")
          connect(2,1,"b")
          connect(2,3,"a")
          connect(3,2,"a")
        end
        assert expected.complete <=> nfa.determinize.complete
      end

    end
  end
end
