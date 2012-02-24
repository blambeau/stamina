require 'stamina_test'
module Stamina
  class AutomataOperationsTest < Test::Unit::TestCase

    def setup
      @dfa = ADL::parse_automaton <<-AUTOMATON
        3 4
        A true false
        B false false
        C false true
        A B a
        B C b
        C C a
        C B b
      AUTOMATON

      @another = ADL::parse_automaton <<-AUTOMATON
        3 3
        A true true
        B false false
        C false true
        A B a
        B C a
        C C a
      AUTOMATON

      @small = ADL::parse_automaton <<-AUTOMATON
        1 1
        S true true
        S S a
      AUTOMATON
    end

    # With names of new states thrown away
    def test_add_states1a
      assert_equal(false, @dfa.accepts?('?'))
      small_init = @dfa.add_automaton(@small)
      @dfa.connect(@dfa.initial_state,small_init,'c')

      assert_equal(4, @dfa.state_count)
      assert_equal(6, @dfa.edge_count)

      check_dfa_unchanged(@dfa)
      assert_equal(true,  @dfa.accepts?('? c'))
      assert_equal(true,  @dfa.accepts?('? c a a a'))
      assert_equal(false, @dfa.accepts?('? c a a b a'))

      assert_raise ArgumentError do
        @dfa.get_state('S') # non-existing state
      end

    end

    # Checks that the supplied automaton matches @dfa
    def check_dfa_unchanged(automaton)
      assert_equal(false, automaton.accepts?('?'))
      assert_equal(false, automaton.accepts?('? a'))
      assert_equal(false, automaton.accepts?('? a c'))
      assert_equal(true,  automaton.accepts?('? a b'))
      assert_equal(true,  automaton.accepts?('? a b a'))
      assert_equal(false, automaton.accepts?('? a b a b'))
      assert_equal(true,  automaton.accepts?('? a b a b b'))
    end

    def test_add_states1b
      another_init = @dfa.add_automaton(@another)

      @dfa.connect(@dfa.initial_state,another_init,'c')

      assert_equal(6, @dfa.state_count)
      assert_equal(8, @dfa.edge_count)

      check_dfa_unchanged(@dfa)
      assert_equal(true,  @dfa.accepts?('? c'))
      assert_equal(false, @dfa.accepts?('? c a'))
      assert_equal(true,  @dfa.accepts?('? c a a a'))
      assert_equal(false, @dfa.accepts?('? c a a b a'))
    end

    # Without throwing away names of new states
    def test_add_states2
      small_init = @dfa.add_automaton(@small,false)
      @dfa.connect(@dfa.initial_state,small_init,'c')

      assert_equal(4, @dfa.state_count)
      assert_equal(6, @dfa.edge_count)

      @dfa.get_state('S') # this one should exist
    end

    # Testing with an empty automaton

    def create_empty_automaton
      empty = ADL::parse_automaton <<-AUTOMATON
        1 0
        B true true
      AUTOMATON
      empty.drop_state(empty.get_state("B"))
      empty
    end

    def test_add_states4a
      empty = create_empty_automaton
      empty.add_automaton(empty,false)

      assert_equal(0, empty.state_count)
      assert_equal(0, empty.edge_count)
    end

    def test_add_states4b
      empty = create_empty_automaton
      empty.add_automaton(empty,true)

      assert_equal(0, empty.state_count)
      assert_equal(0, empty.edge_count)
    end

    def test_add_states5
      @dfa.add_automaton(create_empty_automaton,false)
      assert_equal(3, @dfa.state_count);assert_equal(4, @dfa.edge_count);check_dfa_unchanged(@dfa)
    end

    def test_add_states6
      empty = create_empty_automaton
      initial=empty.add_automaton(@dfa, true)
      initial.initial!
      assert_equal(3, empty.state_count);assert_equal(4, empty.edge_count);check_dfa_unchanged(empty)
    end

    def test_dup_1
      empty = create_empty_automaton
      anotherEmpty = empty.dup

      anotherEmpty.add_state(:accepting => true)
    end

    # Tests that adding states/transitions actually copies them
    def test_add_states_really_copies
      outAOrig_edge1 = @dfa.initial_state.out_edges.select { |e| e.symbol == 'a'}[0]
      outAOrig_edge2 = outAOrig_edge1.to.out_edges.select { |e| e.symbol == 'a'}[0]
      outAN_edge1 = @another.initial_state.out_edges.select { |e| e.symbol == 'a'}[0]
      outAN_edge2 = outAN_edge1.to.out_edges.select { |e| e.symbol == 'a'}[0]

      stateAO_O = @dfa.initial_state
      stateAO_1 = @dfa.step(nil,'a')[0]

      stateAN_O = @another.initial_state
      stateAN_1 = @another.step(nil,'a')[0]

      another_init = @dfa.add_automaton(@another)

      @dfa.connect(@dfa.initial_state,another_init,'c')

      assert_equal(6, @dfa.state_count)
      assert_equal(8, @dfa.edge_count)

      check_dfa_unchanged(@dfa)
      assert_equal(true,  @dfa.accepts?('? c'))


      outA_edge1 = @dfa.initial_state.out_edges.select { |e| e.symbol == 'a'}[0]
      outA_edge2 = outA_edge1.to.out_edges.select { |e| e.symbol == 'a'}[0]

      stateA_O = @dfa.initial_state
      stateA_1 = @dfa.step(nil,'a')[0]

      outB_edge1 = another_init.out_edges.select { |e| e.symbol == 'a'}[0]
      outB_edge2 = outB_edge1.to.out_edges.select { |e| e.symbol == 'a'}[0]

      stateB_O = another_init
      stateB_1 = another_init.step('a')[0]

      assert_same stateAO_O,stateA_O
      assert_same stateAO_1,stateA_1
      assert_not_same stateAN_O,stateB_O
      assert_not_same stateAN_1,stateB_1

      assert_same outAOrig_edge1, outA_edge1
      assert_same outAOrig_edge2, outA_edge2
      assert_not_same outB_edge1, outAN_edge1
      assert_not_same outB_edge2, outAN_edge2
    end



  end # class AutomataOperationsTest
end # module Stamina