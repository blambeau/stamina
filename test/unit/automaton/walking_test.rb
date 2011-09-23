require 'stamina_test'
module Stamina
  class Automaton
    # Tests Walking module on Automaton class
    class WalkingTest < StaminaTest

      # Tests Walking#step on examples
      def test_step_on_examples
        assert_equal([], @small_dfa.step(0, 'b'))
        assert_equal(@small_dfa.ith_states(1), @small_dfa.step(0, 'a'))
        assert_equal(@small_dfa.ith_states(1,3), @small_dfa.step([0,1], 'a').sort)
        assert_equal(@small_dfa.ith_states(1), @small_dfa.step([0,2], 'a').sort)
    
        assert_equal([], @small_nfa.step(0, 'b'))
        assert_equal(@small_nfa.ith_states(1), @small_nfa.step(0, 'a'))
        assert_equal([], @small_nfa.step(2, 'b'))
        assert_equal(@small_nfa.ith_states(2,3), @small_nfa.step(1, 'b').sort)
        assert_equal(@small_nfa.ith_states(0,1), @small_nfa.step([0,3], 'a').sort)
      end
  
      # Tests Walking#dfa_step on examples
      def test_step_on_examples
        assert_equal(nil, @small_dfa.dfa_step(0, 'b'))
        assert_equal(@small_dfa.ith_state(1), @small_dfa.dfa_step(0, 'a'))
        assert_equal(@small_dfa.ith_states(1), @small_dfa.dfa_step([0], 'a'))
        assert_equal(@small_dfa.ith_states(1,3), @small_dfa.dfa_step([0,1], 'a').sort)
        assert_equal(@small_dfa.ith_states(1), @small_dfa.dfa_step([0,2], 'a').sort)
      end
  
      # Tests Walking#delta on examples
      def test_delta_on_examples
        assert_equal([], @small_dfa.delta(0, 'b'))
        assert_equal(@small_dfa.ith_states(1), @small_dfa.delta(0, 'a'))
        assert_equal(@small_dfa.ith_states(1,3), @small_dfa.delta([0,1], 'a').sort)
        assert_equal(@small_dfa.ith_states(1), @small_dfa.delta([0,2], 'a').sort)
    
        assert_equal([], @small_nfa.delta(0, 'b'))
        assert_equal(@small_nfa.ith_states(1), @small_nfa.delta(0, 'a'))
        assert_equal(@small_nfa.ith_states(1,2,3), @small_nfa.delta(2, 'b').sort)
        assert_equal(@small_nfa.ith_states(1,2,3), @small_nfa.delta(1, 'b').sort)
        assert_equal(@small_nfa.ith_states(0,1), @small_nfa.delta([0,3], 'a').sort)
      end
  
      # Tests Walking#dfa_delta on examples
      def test_delta_on_examples
        assert_equal(nil, @small_dfa.dfa_delta(0, 'b'))
        assert_equal(@small_dfa.ith_state(1), @small_dfa.dfa_delta(0, 'a'))
        assert_equal(@small_dfa.ith_states(1,3), @small_dfa.dfa_delta([0,1], 'a').sort)
        assert_equal(@small_dfa.ith_states(1), @small_dfa.dfa_delta([0,2], 'a').sort)
      end
  
      # Tests Walking#split on examples
      def test_split_on_examples
        assert_equal([[], @small_dfa.ith_states(3), []], @small_dfa.split('?'))
        assert_equal([[], @small_dfa.ith_states(3), ['a']], @small_dfa.split('? a'))
        assert_equal([['b'], @small_dfa.ith_states(2), []], @small_dfa.split('? b'))
        assert_equal([['b'], @small_dfa.ith_states(2), ['a']], @small_dfa.split('? b a'))
        assert_equal([['b','c'], @small_dfa.ith_states(0), []], @small_dfa.split('? b c'))
      
        assert_equal([[], @small_nfa.ith_states(0,3), []], @small_nfa.split('?'))
        assert_equal([[], @small_nfa.ith_states(0,3), ['b']], @small_nfa.split('? b'))
        assert_equal([['a'], @small_nfa.ith_states(0,1), []], @small_nfa.split('? a',nil,true))
        assert_equal([['a'], @small_nfa.ith_states(0,1), ['c']], @small_nfa.split('? a c',nil,true))
        assert_equal([['a','b'], @small_nfa.ith_states(1,2,3), []], @small_nfa.split('? a b',nil,true))
      end
  
      # Tests Walking#dfa_split on examples
      def test_split_on_examples
        assert_equal([[], @small_dfa.ith_state(3), []], @small_dfa.dfa_split('?'))
        assert_equal([[], @small_dfa.ith_state(3), ['a']], @small_dfa.dfa_split('? a'))
        assert_equal([['b'], @small_dfa.ith_state(2), []], @small_dfa.dfa_split('? b'))
        assert_equal([['b'], @small_dfa.ith_state(2), ['a']], @small_dfa.dfa_split('? b a'))
        assert_equal([['b','c'], @small_dfa.ith_state(0), []], @small_dfa.dfa_split('? b c'))
        assert_equal([['b','c'], @small_dfa.ith_states(0), []], @small_dfa.dfa_split('? b c',[3]))
      end
  
      # Tests Walking#reached on examples 
      def test_reached_on_examples
        assert_equal([], @small_dfa.reached('? a a'))
        assert_equal(@small_dfa.ith_states(2), @small_dfa.reached('? b'))
        assert_equal(@small_dfa.ith_states(1), @small_dfa.reached('? b c a c'))
        assert_equal(@small_dfa.ith_states(1), @small_dfa.reached('? a c', @small_dfa.ith_state(0)))
        assert_equal(@small_dfa.ith_states(1), @small_dfa.reached('? a c',0))
        assert_equal(@small_dfa.ith_states(1), @small_dfa.reached('? a',[0]))
        assert_equal(@small_dfa.ith_states(1,3), @small_dfa.reached('? a',[0,1]))
        assert_equal(@small_dfa.ith_states(2), @small_dfa.reached('? b',[3,1]))
        assert_equal(@small_dfa.ith_states(2), @small_dfa.reached('? b',[0,3,1]))
      
        assert_equal(@small_nfa.ith_states(0,3), @small_nfa.reached('?').sort)
        assert_equal(@small_nfa.ith_states(0,1), @small_nfa.reached('? a').sort)
        assert_equal(@small_nfa.ith_states(1,2,3), @small_nfa.reached('? a b').sort)
      end

      # Tests Walking#dfa_reached on examples  
      def test_dfa_reached_on_examples
        assert_equal(nil, @small_dfa.dfa_reached('? a a'))
        assert_equal(@small_dfa.ith_state(2), @small_dfa.dfa_reached('? b'))
        assert_equal(@small_dfa.ith_state(1), @small_dfa.dfa_reached('? b c a c'))
        assert_equal(@small_dfa.ith_state(1), @small_dfa.dfa_reached('? a c', @small_dfa.ith_state(0)))
        assert_equal(@small_dfa.ith_state(1), @small_dfa.dfa_reached('? a c',0))
        assert_equal(@small_dfa.ith_states(1), @small_dfa.dfa_reached('? a',[0]))
        assert_equal(@small_dfa.ith_states(1,3), @small_dfa.dfa_reached('? a',[0,1]))
        assert_equal(@small_dfa.ith_states(2), @small_dfa.dfa_reached('? b',[3,1]))
        assert_equal(@small_dfa.ith_states(2), @small_dfa.dfa_reached('? b',[0,3,1]))
      end
  
      # Tests Walking#dfa_reached
      def test_dfa_reached_on_simple_deterministic_automaton
        s0, s1 = nil
        fa = Automaton.new do |fa|
          s0 = fa.add_state(:initial => true)
          s1 = fa.add_state
          fa.connect(s0, s1, 'a')
          fa.connect(s1, s0, 'b')
        end 
        assert_equal(s0, fa.dfa_reached('? '))
        assert_equal(s1, fa.dfa_reached('? a'))
        assert_equal(s0, fa.dfa_reached('? a b'))
        assert_equal(s1, fa.dfa_reached('? a b a'))
        assert_equal(s0, fa.dfa_reached('? a b a b'))
        assert_nil(fa.dfa_reached('? a a'))
        assert_nil(fa.dfa_reached('? b'))
        assert_nil(fa.dfa_reached('? a b b'))
      end
    
      # Tests Walking#reached on a deterministic automaton
      def test_reached_on_simple_deterministic_automaton
        s0, s1 = nil
        fa = Automaton.new do |fa|
          s0 = fa.add_state(:initial => true)
          s1 = fa.add_state
          fa.connect(s0, s1, 'a')
          fa.connect(s1, s0, 'b')
        end 
        assert_equal([s0], fa.reached('?'))
        assert_equal([s1], fa.reached('? a'))
        assert_equal([s0], fa.reached('? a b'))
        assert_equal([s1], fa.reached('? a b a'))
        assert_equal([s0], fa.reached('? a b a b'))
        assert_equal([], fa.reached('? a a'))
        assert_equal([], fa.reached('? b'))
        assert_equal([], fa.reached('? a b b'))
      end
  
      # Tests Walking#reached on a non-deterministic automaton.
      def test_reached_on_non_deterministic_automaton
        s0, s1, s2, s3, s4 = nil
        fa = Automaton.new do |fa|
          s0 = fa.add_state(:initial => true)    #
          s1, s2, s3, s4 = fa.add_n_states(4)    #         s1  -b->  s3
          fa.connect(s0, s1, 'a')                #      a
          fa.connect(s0, s2, 'a')                # s0
          fa.connect(s1, s3, 'b')                #      a
          fa.connect(s2, s4, 'c')                #         s2  -c->  s4
        end                                      #
        assert_equal([], s2.delta('b'))
        assert_equal([s0], fa.reached('?'))
        assert_equal([], fa.reached('? c'))
        assert_equal([s1,s2], fa.reached('? a').sort)
        assert_equal([s3], fa.reached('? a b'))
        assert_equal([s4], fa.reached('? a c'))
        assert_equal([s1,s2], fa.reached('? a').sort)
      
        # add a looping b on s2
        fa.connect(s2, s2, 'b')
        assert_equal([s2,s3], fa.reached('? a b').sort)
    
        # add an epsilon from s2 to s1 
        fa.connect(s2, s1, nil)
        assert_equal([s1,s2], fa.reached('? a').sort)
        assert_equal([s1,s2,s3], fa.reached('? a b').sort)
      end
  
      # Tests Walking#accepts? and Walking#rejects?
      def test_accepts_and_rejects
        fa = Automaton.new do
          add_state(:initial => true)
          add_state(:accepting => true)
          add_state(:error => true)
          add_state(:accepting => true, :error => true)
          connect(0,1,'a')
          connect(1,0,'b')
          connect(0,2,'b')
          connect(1,3,'a')
        end
        assert_equal(false, fa.accepts?("?"))
        assert_equal(true, fa.accepts?("? a"))
        assert_equal(false, fa.accepts?("? a b"))
        assert_equal(true, fa.accepts?("? a b a"))
        assert_equal(false, fa.accepts?("? z"), "not accepts? on no state")
        assert_equal(false, fa.accepts?("? b"), "not accepts? on non accepting error state")
        assert_equal(false, fa.accepts?("? a a"), "not accepts? on accepting error state")
      
        assert_equal(true, fa.rejects?("?"))
        assert_equal(false, fa.rejects?("? a"))
        assert_equal(true, fa.rejects?("? a b"))
        assert_equal(false, fa.rejects?("? a b a"))
        assert_equal(true, fa.rejects?("? z"), "rejects? on no state")
        assert_equal(true, fa.rejects?("? b"), "rejects? on non accepting error state")
        assert_equal(true, fa.rejects?("? a a"), "rejects? on accepting error state")
      end
    
    end # class WalkingTest
  end # class Automaton
end # module Stamina
