require 'stamina_test'
module Stamina
  class Automaton
    class CompleteTest < StaminaTest
    
      def test_on_not_complete
        x, y, z = nil, nil, nil
        dfa = Automaton.new(true) do |fa|
          fa.alphabet = ["a", "b"]
          x = fa.add_state(:initial => true,  :accepting => true)
          y = fa.add_state(:initial => false, :accepting => false)
          fa.connect(0,1,'a')
          fa.connect(1,0,'b')
        end

        assert_equal false, dfa.complete?
        dfa.complete!
        assert_equal true, dfa.complete?

        assert_equal 3, dfa.state_count
        z = dfa.ith_state(2)
        assert_equal z, dfa.dfa_delta(x, "b")
        assert_equal y, dfa.dfa_delta(x, "a")
        assert_equal z, dfa.dfa_delta(y, "a")
        assert_equal x, dfa.dfa_delta(y, "b")
      end

      def test_on_complete
        dfa = Automaton.new(true) do |fa|
          fa.alphabet = ["a"]
          fa.add_state(:initial => true,  :accepting => true)
          fa.add_state(:initial => false, :accepting => false)
          fa.connect(0,1,'a')
          fa.connect(1,0,'a')
        end
        assert_equal true, dfa.complete?
        dfa.complete!
        assert_equal 2, dfa.state_count
      end
 
      def test_it_has_a_non_touching_impl
        dfa = Automaton.new(true) do |fa|
          fa.alphabet = ["a", "b"]
          fa.add_state(:initial => true,  :accepting => true)
          fa.add_state(:initial => false, :accepting => false)
          fa.connect(0,1,'a')
          fa.connect(1,0,'b')
        end
        c = dfa.complete
        assert_equal 2, dfa.state_count
        assert_equal 3, c.state_count
      end

    end # class CompleteTest
  end # class Automaton
end # module Stamina

