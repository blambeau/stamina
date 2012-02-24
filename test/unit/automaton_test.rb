require 'stamina_test'
module Stamina

  class AutomatonTest < StaminaTest

    def test_state_sink_q
      x, y = nil, nil
      Automaton.new(true) do |fa|
        x = fa.add_state(:initial => true,  :accepting => true)
        y = fa.add_state(:initial => false, :accepting => false)
        fa.connect(0,1,'a')
        fa.connect(1,1,'b')
      end
      assert_equal false, x.sink?
      assert_equal true, y.sink?
    end

    # Tests that an automaton can be created with onself=true
    def test_new_on_self
      Automaton.new(true) do |fa|
        fa.add_state(:initial => true)
        add_state(:accepting => true)
        connect(0,1,'a')
        fa.connect(1,0,'b')
      end
    end

    # Tests that an automaton can be created with onself=true
    def test_new_not_on_self
      Automaton.new(false) do |fa|
        fa.add_state(:initial => true)
        fa.add_state(:accepting => true)
        fa.connect(0,1,'a')
        fa.connect(1,0,'b')
      end
    end

    # Tests Automaton documentation example.
    def test_documentation_example
       # Building an automaton for the regular language a(ba)*
       # It's a deterministic one, so we enforce it!
       fa = Automaton.new do
         add_state(:initial => true)
         add_state(:accepting => true)
         connect(0,1,'a')
         connect(1,0,'b')
       end

       # And we now it accepts 'a b a b a', and rejects 'a b' as well as ''
       assert_equal(true, fa.accepts?('? a b a b a'))
       assert_equal(false,fa.accepts?('? a b'))
       assert_equal(true, fa.rejects?('?'))
    end

    ### tests on small dfa #######################################################

    # Tests Automaton#states on examples
    def test_states_on_examples
      assert_equal(4,@small_dfa.states.size)
      assert_equal(4,@small_nfa.states.size)
    end

    # Tests Automaton#edges on examples
    def test_edges_on_examples
      assert_equal(6,@small_dfa.edges.size)
      assert_equal(7,@small_nfa.edges.size)
    end

    # Tests Automaton#state_count on examples
    def test_state_count_on_examples
      assert_equal(4, @small_dfa.state_count)
      assert_equal(4, @small_nfa.state_count)
    end

    # Tests Automaton#edge_count on examples
    def test_edge_count_on_examples
      assert_equal(6, @small_dfa.edge_count)
      assert_equal(7, @small_nfa.edge_count)
    end

    # Tests Automaton#ith_state on examples
    def test_ith_state_on_examples
      @examples.each do |fa|
        states = []
        0.upto(fa.state_count-1) do |i|
          states << fa.ith_state(i)
        end
        assert_equal(fa.states, states)
      end
    end

    # Tests Automaton#ith_states on examples
    def test_ith_states_on_examples
      assert_equal(@small_dfa.states, @small_dfa.ith_states(0,1,2,3))
      assert_equal([@small_dfa.ith_state(1)], @small_dfa.ith_states(1))
      assert_equal(@small_nfa.states, @small_nfa.ith_states(0,1,2,3))
      assert_equal([@small_nfa.ith_state(1)], @small_nfa.ith_states(1))
    end

    # Tests Automaton#ith_edge on examples
    def test_ith_edge_on_examples
      @examples.each do |fa|
        edges = []
        0.upto(fa.edge_count-1) do |i|
          edges << fa.ith_edge(i)
        end
        assert_equal(fa.edges, edges)
      end
    end

    # Tests Automaton#ith_edges on examples
    def test_ith_edges_on_examples
      assert_equal(@small_dfa.edges, @small_dfa.ith_edges(0,1,2,3,4,5))
      assert_equal([@small_dfa.ith_edge(1)], @small_dfa.ith_edges(1))
      assert_equal([@small_dfa.ith_edge(1), @small_dfa.ith_edge(4)], @small_dfa.ith_edges(1,4))
      assert_equal(@small_nfa.edges, @small_nfa.ith_edges(0,1,2,3,4,5,6))
      assert_equal([@small_nfa.ith_edge(1)], @small_nfa.ith_edges(1))
      assert_equal([@small_nfa.ith_edge(1), @small_nfa.ith_edge(4)], @small_nfa.ith_edges(1,4))
    end

    # Tests Automaton#each_state on examples
    def test_each_state_on_examples
      @examples.each do |fa|
        states = []
        fa.each_state {|s| states << s}
        assert_equal(fa.states, states)
      end
    end

    # Tests Automaton#each_edge on examples
    def test_each_state_on_examples
      @examples.each do |fa|
        edges = []
        fa.each_edge {|e| edges << e}
        assert_equal(fa.edges, edges)
      end
    end

    # Tests Automaton#in_edges on examples
    def test_in_edges_on_examples
      assert_equal(@small_dfa.ith_edges(4), @small_dfa.in_edges(0,true))
      assert_equal(@small_dfa.ith_edges(0,5), @small_dfa.in_edges(1,true))
      assert_equal(@small_dfa.ith_edges(1,3), @small_dfa.in_edges(2,true))
      assert_equal(@small_dfa.ith_edges(2), @small_dfa.in_edges(3,true))

      assert_equal(@small_nfa.ith_edges(5), @small_nfa.in_edges(0,true))
      assert_equal(@small_nfa.ith_edges(0,1,6), @small_nfa.in_edges(1,true))
      assert_equal(@small_nfa.ith_edges(2), @small_nfa.in_edges(2,true))
      assert_equal(@small_nfa.ith_edges(3,4), @small_nfa.in_edges(3,true))
    end

    # Tests Automaton#in_edges on examples
    def test_in_edges_and_out_edges_by_state_name
      dfa = ADL.parse_automaton <<-DFA
        2 2
        First true false
        Second false true
        First Second a
        Second First b
      DFA
      assert_equal dfa.ith_edges(0), dfa.in_edges('Second')
      assert_equal dfa.ith_edges(0), dfa.out_edges('First')
    end

    # Tests Automaton#out_edges on examples
    def test_out_edges_on_examples
      assert_equal(@small_dfa.ith_edges(0), @small_dfa.out_edges(0,true))
      assert_equal(@small_dfa.ith_edges(1,2,5), @small_dfa.out_edges(1,true))
      assert_equal(@small_dfa.ith_edges(4), @small_dfa.out_edges(2,true))
      assert_equal(@small_dfa.ith_edges(3), @small_dfa.out_edges(3,true))

      assert_equal(@small_nfa.ith_edges(0), @small_nfa.out_edges(0,true))
      assert_equal(@small_nfa.ith_edges(1,2,3), @small_nfa.out_edges(1,true))
      assert_equal(@small_nfa.ith_edges(4,6), @small_nfa.out_edges(2,true))
      assert_equal(@small_nfa.ith_edges(5), @small_nfa.out_edges(3,true))
    end

    # Tests Automaton#in_symbols on examples
    def test_in_symbols_on_examples
      assert_equal(['c'], @small_dfa.in_symbols(0,true))
      assert_equal(['a','c'], @small_dfa.in_symbols(1,true))
      assert_equal(['b'], @small_dfa.in_symbols(2,true))
      assert_equal(['a'], @small_dfa.in_symbols(3,true))

      assert_equal(['a'], @small_nfa.in_symbols(0,true))
      assert_equal([nil,'a'], @small_nfa.in_symbols(1,true))
      assert_equal(['b'], @small_nfa.in_symbols(2,true))
      assert_equal(['b','c'], @small_nfa.in_symbols(3,true))
    end

    # Tests Automaton#out_edges on examples
    def test_out_symbols_on_examples
      assert_equal(['a'], @small_dfa.out_symbols(0,true))
      assert_equal(['a', 'b', 'c'], @small_dfa.out_symbols(1,true))
      assert_equal(['c'], @small_dfa.out_symbols(2,true))
      assert_equal(['b'], @small_dfa.out_symbols(3,true))

      assert_equal(['a'], @small_nfa.out_symbols(0,true))
      assert_equal([nil, 'b'], @small_nfa.out_symbols(1,true))
      assert_equal([nil, 'c'], @small_nfa.out_symbols(2,true))
      assert_equal(['a'], @small_nfa.out_symbols(3,true))
    end

    # Tests Automaton#adjacent_states on examples
    def test_adjacent_states_on_examples
      assert_equal(@small_dfa.ith_states(1,2), @small_dfa.adjacent_states(0).sort)
      assert_equal(@small_dfa.ith_states(0,1,2,3), @small_dfa.adjacent_states(1).sort)
      assert_equal(@small_dfa.ith_states(0,1,3), @small_dfa.adjacent_states(2).sort)
      assert_equal(@small_dfa.ith_states(1,2), @small_dfa.adjacent_states(3).sort)

      assert_equal(@small_nfa.ith_states(1,3), @small_nfa.adjacent_states(0).sort)
      assert_equal(@small_nfa.ith_states(0,1,2,3), @small_nfa.adjacent_states(1).sort)
      assert_equal(@small_nfa.ith_states(1,3), @small_nfa.adjacent_states(2).sort)
      assert_equal(@small_nfa.ith_states(0,1,2), @small_nfa.adjacent_states(3).sort)
    end

    # Tests Automaton#in_adjacent_states on examples
    def test_in_adjacent_states_on_examples
      assert_equal(@small_dfa.ith_states(2), @small_dfa.in_adjacent_states(0).sort)
      assert_equal(@small_dfa.ith_states(0,1), @small_dfa.in_adjacent_states(1).sort)
      assert_equal(@small_dfa.ith_states(1,3), @small_dfa.in_adjacent_states(2).sort)
      assert_equal(@small_dfa.ith_states(1), @small_dfa.in_adjacent_states(3).sort)

      assert_equal(@small_nfa.ith_states(3), @small_nfa.in_adjacent_states(0).sort)
      assert_equal(@small_nfa.ith_states(0,1,2), @small_nfa.in_adjacent_states(1).sort)
      assert_equal(@small_nfa.ith_states(1), @small_nfa.in_adjacent_states(2).sort)
      assert_equal(@small_nfa.ith_states(1,2), @small_nfa.in_adjacent_states(3).sort)
    end

    # Tests Automaton#out_adjacent_states on examples
    def test_out_adjacent_states_on_examples
      assert_equal(@small_dfa.ith_states(1), @small_dfa.out_adjacent_states(0).sort)
      assert_equal(@small_dfa.ith_states(1,2,3), @small_dfa.out_adjacent_states(1).sort)
      assert_equal(@small_dfa.ith_states(0), @small_dfa.out_adjacent_states(2).sort)
      assert_equal(@small_dfa.ith_states(2), @small_dfa.out_adjacent_states(3).sort)

      assert_equal(@small_nfa.ith_states(1), @small_nfa.out_adjacent_states(0).sort)
      assert_equal(@small_nfa.ith_states(1,2,3), @small_nfa.out_adjacent_states(1).sort)
      assert_equal(@small_nfa.ith_states(1,3), @small_nfa.out_adjacent_states(2).sort)
      assert_equal(@small_nfa.ith_states(0), @small_nfa.out_adjacent_states(3).sort)
    end

    # Tests Automaton#initial_states on examples
    def test_initial_states_on_examples
      assert_equal([@small_dfa.ith_state(3)], @small_dfa.initial_states())
      assert_equal(@small_nfa.ith_states(0,3), @small_nfa.initial_states().sort)
    end

    # Tests Automaton#initial_state on examples
    def test_initial_state_on_examples
      assert_equal(@small_dfa.ith_state(3), @small_dfa.initial_state())
    end

    # Tests Automaton#step on examples
    def test_step_on_examples
      assert_equal([], @small_dfa.step(0,'b'))
      @small_dfa.each_state do |s|
        s.out_edges.each do |e|
          assert_equal([e.target], @small_dfa.step(s,e.symbol))
        end
      end

      assert_equal([], @small_nfa.step(0, 'b'))
      assert_equal(@small_nfa.ith_states(1), @small_nfa.step(0, 'a'))
      assert_equal(@small_nfa.ith_states(2,3), @small_nfa.step(1, 'b'))
      assert_equal(@small_nfa.ith_states(1), @small_nfa.step(1, nil))
    end

    # Tests Automaton#dfa_step on examples
    def test_dfa_step_on_examples
      assert_equal(nil, @small_dfa.dfa_step(0,'b'))
      @small_dfa.each_state do |s|
        s.out_edges.each do |e|
          assert_equal(e.target, @small_dfa.dfa_step(s,e.symbol))
        end
      end
    end

    # Tests Automaton#delta on examples
    def test_delta_on_examples
      assert_equal([], @small_dfa.delta(0,'b'))
      @small_dfa.each_state do |s|
        s.out_edges.each do |e|
          assert_equal([e.target], @small_dfa.delta(s,e.symbol))
        end
      end

      assert_equal([], @small_nfa.delta(0,'b'))
      assert_equal(@small_nfa.ith_states(1,2,3), @small_nfa.delta(1, 'b').sort)
      assert_equal(@small_nfa.ith_states(), @small_nfa.delta(1, 'a').sort)
      assert_equal(@small_nfa.ith_states(1), @small_nfa.delta(0, 'a').sort)
      assert_equal(@small_nfa.ith_states(1,2,3), @small_nfa.delta(2, 'b').sort)
    end

    # Tests Automaton#dfa_delta on examples
    def test_dfa_delta_on_examples
      assert_equal(nil, @small_dfa.dfa_delta(0,'b'))
      @small_dfa.each_state do |s|
        s.out_edges.each do |e|
          assert_equal(e.target, @small_dfa.dfa_delta(s,e.symbol))
        end
      end
    end

    ### tests by methods #########################################################

    # Tests Automaton#add_state
    def test_add_state
      Automaton.new(false) do |fa|
        s0 = fa.add_state
        assert_equal(1, fa.state_count)
        assert_equal(false, s0.initial?)
        assert_equal(false, s0.accepting?)

        s1 = fa.add_state(:initial => true)
        assert_equal(2, fa.state_count)
        assert_equal(true, s1.initial?)
        assert_equal(false, s1.accepting?)

        s2 = fa.add_state(:initial => true, :accepting => true)
        assert_equal(3, fa.state_count)
        assert_equal(true, s2.initial?)
        assert_equal(true, s2.accepting?)

        s3 = fa.add_state(:myownkey => "blambeau")
        assert_equal(4, fa.state_count)
        assert_equal(false, s3.initial?)
        assert_equal(false, s3.accepting?)
        assert_equal("blambeau", s3[:myownkey])

        assert_equal(0, fa.edge_count)
      end
    end

    # Simply tests that aliases of add_state work.
    def test_add_state_aliases
      Automaton.new(false) do |fa|
        assert_not_nil(s0 = fa.add_state(:initial => true))
        assert_not_nil(s1 = fa.create_state)
        assert_not_nil fa.add_edge(s0,s1, 'a')
      end
    end

    # Tests Automaton#add_edge
    def test_add_edge
      Automaton.new(false) do |fa|
        s0 = fa.add_state(:initial => true)
        s1 = fa.add_state(:initial => false, :accepting => true)
        edge = fa.add_edge(s0, s1, {:symbol => 'a'})

        # check automaton
        assert_equal(2, fa.state_count)
        assert_equal(1, fa.edge_count)

        # check edge
        assert_equal('a', edge.symbol)
        assert_equal(s0, edge.source)
        assert_equal(s0, edge.from)
        assert_equal(s1, edge.target)
        assert_equal(s1, edge.to)

        # check states
        assert_equal([edge], s0.out_edges)
        assert_equal([edge], s1.in_edges)
        assert_equal(true, s0.deterministic?)
        assert_equal(true, s1.deterministic?)
      end
    end

    # Simply tests that aliases of add_edge work.
    def test_add_edge_aliases
      Automaton.new(false) do |fa|
        s0 = fa.add_state(:initial => true)
        s1 = fa.create_state
        assert_not_nil fa.add_edge(s0,s1, 'a')
        assert_not_nil fa.create_edge(s0,s1,'b')
        assert_not_nil fa.connect(s0,s1,'c')
      end
    end

    # Tests queries of states by names
    def test_state_names_1
        s0,s1,s2 = nil,nil,nil
        simple_dfa = Automaton.new(false) do |fa|
          s0 = fa.add_state(:initial => true, :name => 'A')
          s1 = fa.add_state(:accepting => true, :name => 'B')
          s2 = fa.add_state(:name => 'C')
          fa.connect(s0, s1, 'a')
          fa.connect(s1, s1, 'b')
          fa.connect(s1, s2, 'c')
        end
      assert_raise ArgumentError do
        simple_dfa.get_state(56) # wrong type
      end
      assert_raise ArgumentError do
        simple_dfa.get_state('T') # non-existing name
      end

      assert_raise ArgumentError do
        simple_dfa.get_state('') # non-existing state
      end

      assert_raise ArgumentError do
        simple_dfa.get_state(nil) # nil name
      end
      assert_equal s0,simple_dfa.get_state('A')
      assert_equal s1,simple_dfa.get_state('B')
      assert_equal s2,simple_dfa.get_state('C')
    end

    # tests queries of states by names
    def test_state_names_2
      simple_dfa = Automaton.new(false) do |fa|
         fa.add_state(:initial => true)
      end
      assert_raise ArgumentError do
        simple_dfa.get_state('') # non-existing state
      end
    end

    # Tests Automaton#drop_state
    def test_drop_state
      s0, s1, e00, e01, e10, e11 = nil
      fa = Automaton.new do |fa|
        s0 = fa.add_state(:initial => true)
        s1 = fa.add_state
        e01 = fa.connect(s0, s1, 'a')
        e00 = fa.connect(s0, s0, 'b')
        e10 = fa.connect(s1, s0, 'b')
        e11 = fa.connect(s1, s1, 'a')
      end

      fa.drop_state(s1)
      assert_equal(false, fa.states.include?(s1))
      assert_equal(1, fa.state_count)
      assert_equal(1, fa.edge_count)
      assert_equal(-1, s1.index)
      assert_equal(-1, e01.index)
      assert_equal(-1, e10.index)
      assert_equal(-1, e11.index)
      assert_equal(0, s0.index)
      assert_equal(0, e00.index)
    end

    def test_drop_state_respects_indexing
      fa = Stamina::ADL.parse_automaton <<-EOF
        5 5
        0 true false
        1 false false
        2 false false
        3 false false
        4 false false
        0 1 a
        0 2 b
        1 2 b
        2 3 a
        3 4 b
      EOF
      fa.drop_state(1)
      assert_equal 4, fa.state_count
    end

    # Tests Automaton#drop_state
    def test_drop_state_aliases
      s0, s1, e00, e01, e10, e11 = nil
      fa = Automaton.new do |fa|
        s0 = fa.add_state(:initial => true)
        s1 = fa.add_state
        e01 = fa.connect(s0, s1, 'a')
        e00 = fa.connect(s0, s0, 'b')
        e10 = fa.connect(s1, s0, 'b')
        e11 = fa.connect(s1, s1, 'a')
      end

      fa.delete_state(s1)
      assert_equal(1, fa.state_count)
      assert_equal(1, fa.edge_count)
    end

    def test_same_state_cannot_be_dropped_twice
      s0, s1, e00, e01, e10, e11 = nil
      fa = Automaton.new do |fa|
        s0 = fa.add_state(:initial => true)
        s1 = fa.add_state
        e01 = fa.connect(s0, s1, 'a')
        e00 = fa.connect(s0, s0, 'b')
        e10 = fa.connect(s1, s0, 'b')
        e11 = fa.connect(s1, s1, 'a')
      end

      fa.drop_state(s1)
      assert_equal(false, fa.states.include?(s1))
      assert_raise ArgumentError do
        fa.drop_state(s1)
      end
    end

    # Tests Automaton#drop_states
    def test_drop_states
      s0, s1, s2, e00, e01, e10, e11, e02, e21 = nil
      fa = Automaton.new do |fa|
        s0 = fa.add_state(:initial => true)
        s1, s2 = fa.add_n_states(2)
        e01 = fa.connect(s0, s1, 'a')
        e00 = fa.connect(s0, s0, 'b')
        e10 = fa.connect(s1, s0, 'b')
        e11 = fa.connect(s1, s1, 'a')
        e02 = fa.connect(s0, s2, 'c')
        e21 = fa.connect(s2, s1, 'a')
      end

      fa.drop_states(s1,s2)
      assert_equal(1, fa.state_count)
      assert_equal(1, fa.edge_count)
      assert_equal(-1, s1.index)
      assert_equal(-1, s2.index)
      assert_equal(false, fa.states.include?(s1))
      assert_equal(false, fa.states.include?(s2))
    end

    # Tests Automaton#drop_edge
    def test_drop_edge
      s0, s1, e01, e10 = nil
      fa = Automaton.new do |fa|
        s0 = fa.add_state(:initial => true)
        s1 = fa.add_state
        e01 = fa.connect(s0, s1, 'a')
        e10 = fa.connect(s1, s0, 'b')
      end

      # we drop second edge
      fa.drop_edge(e10)
      assert_equal(2, fa.state_count)
      assert_equal(1, fa.edge_count)
      assert_equal(0, e01.index, 'First edge index has not changed')

      # connect it again
      e10 = fa.connect(s1, s0, 'b')

      # we drop the first one this time
      fa.drop_edge(e01)
      assert_equal(2, fa.state_count)
      assert_equal(1, fa.edge_count)
      assert_equal(0, e10.index, 'Second edge became first')
    end

    # Tests Automaton#drop_edge
    def test_drop_edge_by_index
      s0, s1, e01, e10 = nil
      fa = Automaton.new do |fa|
        s0 = fa.add_state(:initial => true)
        s1 = fa.add_state
        e01 = fa.connect(s0, s1, 'a')
        e10 = fa.connect(s1, s0, 'b')
      end

      # we drop second edge
      fa.drop_edge(1)
      assert_equal(2, fa.state_count)
      assert_equal(1, fa.edge_count)
      assert_equal(0, e01.index, 'First edge index has not changed')
    end

    # Tests aliases of Automaton#drop_edge
    def test_drop_edge_aliases
      s0, s1, e01, e10 = nil
      fa = Automaton.new do |fa|
        s0 = fa.add_state(:initial => true)
        s1 = fa.add_state
        e01 = fa.connect(s0, s1, 'a')
        e10 = fa.connect(s1, s0, 'b')
      end

      # we drop second edge
      fa.delete_edge(e10)
      assert_equal(2, fa.state_count)
      assert_equal(1, fa.edge_count)
      assert_equal(0, e01.index, 'First edge index has not changed')
    end

    # Tests that an edge cannot be dropped twice
    def test_same_edge_cannot_be_dropped_twice
      s0, s1, e01, e10 = nil
      fa = Automaton.new do |fa|
        s0 = fa.add_state(:initial => true)
        s1 = fa.add_state
        e01 = fa.connect(s0, s1, 'a')
        e10 = fa.connect(s1, s0, 'b')
      end

      # we drop first edge
      fa.drop_edge(e01)

      # cannot drop it again
      assert_raise ArgumentError do
        fa.drop_edge(e01)
      end
    end

    # Tests Automaton#drop_edges
    def test_drop_edges
      s0, s1, e01, e10, e11 = nil
      fa = Automaton.new do |fa|
        s0 = fa.add_state(:initial => true)
        s1 = fa.add_state
        e10 = fa.connect(s1, s0, 'b')
        e01 = fa.connect(s0, s1, 'a')
        e11 = fa.connect(s1, s1, 'a')
      end

      fa.drop_edges(e10,e11)
      assert_equal(2, fa.state_count)
      assert_equal(1, fa.edge_count)
      assert_equal(0, e01.index)
    end

    # Tests that Automaton#drop_edges allows removing all edges
    def test_drop_edges_recognizes_sub_transaction
      s0, ea, eb, ec = nil
      fa = Automaton.new do |fa|
        s0 = fa.add_state(:initial => true)
        ea = fa.connect(s0, s0, 'a')
        eb = fa.connect(s0, s0, 'b')
        ec = fa.connect(s0, s0, 'c')
      end
      fa.drop_edges(ea, eb, ec)
      assert_equal(0, fa.edge_count)
      assert_equal(0, s0.in_edges.size)
      assert_equal(0, s0.out_edges.size)
    end

    # Tests Automaton#drop_edges
    def test_drop_edges_allow_any_order_of_arguments
      s0, s1, e01, e10, e11 = nil
      fa = Automaton.new do |fa|
        s0 = fa.add_state(:initial => true)
        s1 = fa.add_state
        e10 = fa.connect(s1, s0, 'b')
        e01 = fa.connect(s0, s1, 'a')
        e11 = fa.connect(s1, s1, 'a')
      end

      fa.drop_edges(e11,e10)
      assert_equal(2, fa.state_count)
      assert_equal(1, fa.edge_count)
      assert_equal(0, e01.index)
    end

    # Tests aliases of Automaton#drop_edges
    def test_drop_edges_aliases
      s0, s1, e01, e10, e11 = nil
      fa = Automaton.new do |fa|
        s0 = fa.add_state(:initial => true)
        s1 = fa.add_state
        e10 = fa.connect(s1, s0, 'b')
        e01 = fa.connect(s0, s1, 'a')
        e11 = fa.connect(s1, s1, 'a')
      end

      fa.delete_edges(e10,e11)
      assert_equal(2, fa.state_count)
      assert_equal(1, fa.edge_count)
      assert_equal(0, e01.index)
    end

    # Tests Automaton#edges on invalid edge arguments
    def test_drop_edges_detects_invalid_edges
      s0, s1, e01, e10, e11 = nil
      fa = Automaton.new do |fa|
        s0 = fa.add_state(:initial => true)
        s1 = fa.add_state
        e10 = fa.connect(s1, s0, 'b')
        e01 = fa.connect(s0, s1, 'a')
        e11 = fa.connect(s1, s1, 'a')
      end

      fa.drop_edge(e10)
      assert_raise ArgumentError do
        fa.drop_edges(e11,e10)
      end
      assert_equal(2, fa.state_count)
      assert_equal(2, fa.edge_count)
    end

    ### tests by scenarios #######################################################

    # Tests creating an automaton for the empty regular language
    def test_automaton_of_empty_language
      fa, s0 = nil
      assert_nothing_raised do
        fa = Automaton.new do |fa|
          s0 = fa.add_state(:initial => true, :accepting => false)
        end
      end
      assert_equal(1, fa.state_count)
      assert_equal(0, fa.edge_count)
      assert_equal(true, fa.deterministic?)
      assert_equal([s0], fa.initial_states)
      assert_equal(s0, fa.initial_state)
      assert_equal([s0], fa.states)
      assert_equal([], fa.edges)
      assert_equal([], fa.in_edges(s0))
      assert_equal([], fa.out_edges(s0))
      assert_equal([], fa.in_symbols(s0))
      assert_equal([], fa.out_symbols(s0))
      assert_equal([], fa.adjacent_states(s0))
      assert_equal([], fa.in_adjacent_states(s0))
      assert_equal([], fa.out_adjacent_states(s0))
    end

    # Tests creating an automaton for the regular language that only accepts the
    # empty string.
    def test_automaton_of_lambda_language
      fa, s0 = nil
      assert_nothing_raised do
        fa = Automaton.new do |fa|
          s0 = fa.add_state(:initial => true, :accepting => true)
        end
      end
      assert_equal(1, fa.state_count)
      assert_equal(0, fa.edge_count)
      assert_equal([s0], fa.states)
      assert_equal(true, fa.deterministic?)
      assert_equal([s0], fa.initial_states)
      assert_equal(s0, fa.initial_state)
      assert_equal([], fa.edges)
      assert_equal([], fa.in_edges(s0))
      assert_equal([], fa.out_edges(s0))
      assert_equal([], fa.in_symbols(s0))
      assert_equal([], fa.out_symbols(s0))
      assert_equal([], fa.adjacent_states(s0))
      assert_equal([], fa.in_adjacent_states(s0))
      assert_equal([], fa.out_adjacent_states(s0))
    end

    # Tests that automaton can be created with nil symbols on edges
    def test_automaton_with_epsilon
      fa, s0, s1, edge = nil
      assert_nothing_raised do
        fa = Automaton.new(false) do |fa|
          s0 = fa.add_state(:initial => true, :accepting => true)
          s1 = fa.add_state
          edge = fa.connect(s0, s1, {:symbol => nil})
          assert_equal(nil, edge.symbol)
        end
      end
      assert_equal(false, fa.deterministic?)
      assert_equal([s0,s1], fa.initial_states.sort)
      assert_equal(true, fa.initial_states.include?(fa.initial_state))
    end

    # Tests creation an automaton with one accepting state with looping 'a'
    # symbol.
    def test_automaton_of_whole_langage_on_a
      fa, s0, e0 = nil
      assert_nothing_raised do
        fa = Automaton.new do |fa|
          s0 = fa.add_state(:initial => true, :accepting => true)
          e0 = fa.add_edge(s0, s0, {:symbol => 'a'})
        end
      end

      # check the whole automaton
      assert_equal(1, fa.state_count)
      assert_equal(1, fa.edge_count)
      assert_equal([s0], fa.states)
      assert_equal([e0], fa.edges)
      assert_equal(true, fa.deterministic?)
      assert_equal([s0], fa.initial_states)
      assert_equal(s0, fa.initial_state)
      assert_equal([e0], fa.in_edges(s0))
      assert_equal([e0], fa.out_edges(s0))
      assert_equal(['a'], fa.in_symbols(s0))
      assert_equal(['a'], fa.out_symbols(s0))
      assert_equal([s0], fa.adjacent_states(s0))
      assert_equal([s0], fa.in_adjacent_states(s0))
      assert_equal([s0], fa.out_adjacent_states(s0))
    end

    # Tests creating a simple deterministic automaton
    def test_deterministic_fa_with_two_states
      s0, s1, e01, e10, fa = nil

      # automaton construction, should not raise anything
      fa = Automaton.new do |a|
        s0 = a.add_state(:initial => true)
        s1 = a.add_state(:accepting => true)
        e01 = a.add_edge(s0, s1, 'a')
        e10 = a.add_edge(s1, s0, 'b')
      end

      # check automaton
      assert_equal(2, fa.state_count)
      assert_equal(2, fa.edge_count)
      assert_equal(true, fa.deterministic?)
      assert_equal([s0], fa.initial_states)
      assert_equal(s0, fa.initial_state)
      assert_equal([s0,s1], fa.states)
      assert_equal([e01,e10], fa.edges)

      # check state s0
      assert_equal(true, s0.initial?)
      assert_equal(false, s0.accepting?)
      assert_equal(true, s0.deterministic?)
      assert_equal([e01], s0.out_edges)
      assert_equal([e10], s0.in_edges)

      # check state s1
      assert_equal(false, s1.initial?)
      assert_equal(true, s1.accepting?)
      assert_equal(true, s1.deterministic?)
      assert_equal([e10], s1.out_edges)
      assert_equal([e01], s1.in_edges)

      # check edge 01
      assert_equal('a', e01.symbol)
      assert_equal(s0, e01.source)
      assert_equal(s1, e01.target)

      # check edge 10
      assert_equal('b', e10.symbol)
      assert_equal(s1, e10.source)
      assert_equal(s0, e10.target)

      # check the whole automaton
      assert_equal(2, fa.state_count)
      assert_equal(2, fa.edge_count)
      assert_equal([s0, s1], fa.states)
      assert_equal([e01, e10], fa.edges)
      assert_equal([e10], fa.in_edges(s0))
      assert_equal([e01], fa.out_edges(s0))
      assert_equal(['b'], fa.in_symbols(s0))
      assert_equal(['a'], fa.out_symbols(s0))
      assert_equal([e01], fa.in_edges(s1))
      assert_equal([e10], fa.out_edges(s1))
      assert_equal(['a'], fa.in_symbols(s1))
      assert_equal(['b'], fa.out_symbols(s1))
      assert_equal([s1], fa.adjacent_states(s0))
      assert_equal([s1], fa.in_adjacent_states(s0))
      assert_equal([s1], fa.out_adjacent_states(s0))
      assert_equal([s0], fa.adjacent_states(s1))
      assert_equal([s0], fa.in_adjacent_states(s1))
      assert_equal([s0], fa.out_adjacent_states(s1))

      # check that it is recognized as a deterministic automaton
      assert_equal true, fa.deterministic?
    end

    # Tests nfa.deterministic? on documentation example
    def test_documentation_example2
      # create some automaton (here a non deterministic automaton)
      nfa = Automaton.new do |fa|
        s0 = fa.add_state(:initial => true, :accepting => false)
        s1 = fa.add_state(:initial => false, :accepting => true)
        s2 = fa.add_state(:initial => false, :accepting => true)
        fa.add_edge(s0, s1, 'a')
        fa.add_edge(s0, s2, 'a')
      end

      # check that it is recognized as a non deterministic one
      assert_equal false,nfa.deterministic?
    end

    # Tests Node#delta on a deterministic automaton
    def test_state_delta_on_deterministic
      nfa, s0, s1, s2 = nil
      nfa = Automaton.new do |fa|
        s0 = fa.add_state(:initial => true)
        s1, s2 = fa.add_state, fa.add_state
        fa.connect(s0, s1, 'a')
        fa.connect(s0, s2, 'b')
        fa.connect(s1, s0, 'b')
        fa.connect(s1, s2, 'c')
      end
      assert_equal(true, nfa.deterministic?)

      # letting state choose its data-structure
      assert_equal([s1], s0.delta('a'))
      assert_equal([s2], s0.delta('b'))
      assert_equal([], s0.delta('c'))
      assert_equal([s0], s1.delta('b'))
      assert_equal([s2], s1.delta('c'))
    end

    # Tests Node#delta on a non deterministic automaton
    def test_state_delta_on_non_deterministic
      fa, s0, s1, s2 = nil
      fa = Automaton.new do |fa|
        s0 = fa.add_state(:initial => true)
        s1, s2 = fa.add_state, fa.add_state
        fa.connect(s0, s1, 'a')
        fa.connect(s0, s2, 'a')
        fa.connect(s1, s1, 'b')
        fa.connect(s1, s2, 'b')
      end
      assert_equal(false, fa.deterministic?)
      assert_equal([s1,s2], s0.delta('a').sort)
      assert_equal([], s0.delta('c').sort)
      assert_equal([s1,s2], s1.delta('b').sort)
      assert_equal([], s2.delta('a').sort)
      assert_equal([], s2.delta('b').sort)
    end

    # Tests Node#delta on a non deterministic automaton with epsilon letters
    def test_state_delta_on_non_deterministic_with_epsilon
      #
      # tests on s0 -a-> s1 -a-> s2
      # with a looping nil on s1
      #
      fa, s0, s1, s2, s3, s4 = nil
      fa = Automaton.new do |fa|
        s0 = fa.add_state(:initial => true)
        s1, s2 = fa.add_state, fa.add_state
        fa.connect(s0,s1,'a')
        fa.connect(s1,s1,nil)
        fa.connect(s1,s2,'a')
      end
      assert_equal(false, fa.deterministic?)
      assert_equal([], s0.delta('b'))
      assert_equal([s1], s0.delta('a'))
      assert_equal([s2], s1.delta('a'))
      assert_equal([s1], s1.delta(nil))

      #
      # tests on s0 -a-> s1 -nil-> s2
      #
      fa = Automaton.new do |fa|
        s0 = fa.add_state(:initial => true)
        s1, s2 = fa.add_state, fa.add_state
        fa.connect(s0,s1,'a')
        fa.connect(s1,s2,nil)
      end
      assert_equal(false, fa.deterministic?)
      assert_equal([], s0.delta(nil))
      assert_equal([s1,s2], s0.delta('a').sort)
      assert_equal([], s1.delta('a'))
      assert_equal([s2], s1.delta(nil))

      #
      # tests on s0 -a-> s1 -nil-> s2 -a-> s3
      #
      fa = Automaton.new do |fa|
        s0 = fa.add_state(:initial => true)
        s1, s2, s3 = fa.add_state, fa.add_state, fa.add_state
        fa.connect(s0,s1,'a')
        fa.connect(s1,s2,nil)
        fa.connect(s2,s3,'a')
      end
      assert_equal(false, fa.deterministic?)
      assert_equal([], s0.delta(nil))
      assert_equal([s1,s2], s0.delta('a').sort)
      assert_equal([s3], s1.delta('a'))
      assert_equal([s3], s2.delta('a'))
      assert_equal([s2], s1.delta(nil))

      # s0 -a-> s1 -nil-> s2
      #         s1  <-a-  s1
      #         s1<->a
      fa = Automaton.new do |fa|
        s0 = fa.add_state(:initial => true)
        s1, s2 = fa.add_state, fa.add_state
        fa.connect(s0,s1,'a')
        fa.connect(s1,s1,'a')
        fa.connect(s1,s2,nil)
        fa.connect(s2,s1,'a')
      end
      assert_equal(false, fa.deterministic?)
      assert_equal([s1,s2], s0.delta('a').sort)
      assert_equal([s1,s2], s1.delta('a').sort)
      assert_equal([s1,s2], s2.delta('a').sort)

      # s0 -nil-> s1 -a-> s2 -nil-> s3
      #           s1 -a-> s4
      fa = Automaton.new do |fa|
        s0 = fa.add_state(:initial => true)
        s1, s2, s3, s4 = fa.add_n_states(4)
        fa.connect(s0,s1,nil)
        fa.connect(s1,s2,'a')
        fa.connect(s2,s3,nil)
        fa.connect(s1,s4,'a')
      end
      assert_equal(false, fa.deterministic?)
      assert_equal([s1], s0.delta(nil))
      assert_equal([s2,s3,s4], s0.delta('a').sort)
      assert_equal([s2,s3,s4], s1.delta('a').sort)
    end

    # Tests State#dfa_delta on a deterministic automaton
    def test_state_dfa_delta_on_deterministic
      fa, s0, s1, s2 = nil
      fa = Automaton.new do |fa|
        s0 = fa.add_state(:initial => true)
        s1, s2 = fa.add_state, fa.add_state
        fa.connect(s0, s1, 'a')
        fa.connect(s0, s2, 'b')
        fa.connect(s1, s0, 'b')
        fa.connect(s1, s2, 'c')
      end
      assert_equal(true, fa.deterministic?)

      # letting state choose its data-structure
      assert_equal(s1, s0.dfa_delta('a'))
      assert_equal(s2, s0.dfa_delta('b'))
      assert_equal(nil, s0.dfa_delta('c'))
      assert_equal(s0, s1.dfa_delta('b'))
      assert_equal(s2, s1.dfa_delta('c'))
    end

    # Tests State#epsilon_closure
    def test_epsilon_closure_on_non_deterministic_automaton
      s0, s1, s2, s3, s4 = nil
      fa = Automaton.new do |fa|
        s0 = fa.add_state(:initial => true)    #
        s1, s2, s3, s4 = fa.add_n_states(4)    #         s1  -b->  s3
        fa.connect(s0, s1, 'a')                #      a
        fa.connect(s0, s2, 'a')                # s0
        fa.connect(s1, s3, 'b')                #      a
        fa.connect(s2, s4, 'c')                #         s2  -c->  s4
      end                                      #
      fa.states.each do |s|
        assert_equal([s], s.epsilon_closure)
      end

      fa.connect(s2, s2, 'b')
      assert_equal([s2], s2.delta('b'))

      fa.connect(s2, s1, nil)
      assert_equal([s1], s2.step(nil))
      assert_equal([s1,s2], s2.epsilon_closure.sort)
      assert_equal([s1,s2,s3], s2.delta('b').sort)
    end

    # Tests Walking#walk on a non-deterministic automaton.
    def test_state_delta_on_non_deterministic_automaton_from_walkbug
      s0, s1, s2, s3, s4 = nil
      fa = Automaton.new do |fa|
        s0 = fa.add_state(:initial => true)
        s1, s2, s3, s4 = fa.add_n_states(4)
        fa.connect(s0, s1, 'a')
        fa.connect(s0, s2, 'a')
        fa.connect(s1, s3, 'b')
        fa.connect(s2, s4, 'c')
        fa.connect(s2, s2, 'b')
        fa.connect(s2, s1, nil)
      end
      assert_equal([s1,s2,s3], s2.delta('b').sort)
    end

    ### Dup test section ###########################################################

    def test_automaton_can_be_duplicated
      dup = @small_dfa.dup
      assert_equal @small_dfa.state_count, dup.state_count
      assert_equal @small_dfa.edge_count, dup.edge_count
    end

    ### Alphabet test section ######################################################

    def test_alphabet_on_examples
      assert_equal ['a', 'b', 'c'], @small_dfa.alphabet
      assert_equal ['a', 'b', 'c'], @small_nfa.alphabet
    end

    def test_valid_alphabet_may_be_set
      dfa = @small_dfa.dup
      dfa.alphabet = ['c', 'a', 'b', 'z']
      assert_equal ['a','b','c','z'], dfa.alphabet
    end

    def test_invalid_alphabet_cannot_be_set
      dfa = @small_dfa.dup
      assert_raise ArgumentError do
        dfa.alphabet = ['a', 'b']
      end
      assert_raise ArgumentError do
        dfa.alphabet = ['a', 'a', 'b']
      end
      assert_raise ArgumentError do
        dfa.alphabet = ['a', 'b', nil]
      end
    end

    ### tests initial state cache ##################################################
    def test_initial_state_cache_works_correctly
      dfa = Stamina::ADL.parse_automaton <<-EOF
        2 2
        0 true false
        1 false true
        0 1 a
        1 0 b
      EOF
      initial, other = dfa.ith_state(0), dfa.ith_state(1)
      assert_equal initial, dfa.initial_state
      initial[:hello] = "world"
      assert_equal initial, dfa.initial_state
      dfa.ith_state(0)[:initial] = false
      dfa.ith_state(1)[:initial] = true
      assert_equal other, dfa.initial_state
    end

  end

end # module Stamina