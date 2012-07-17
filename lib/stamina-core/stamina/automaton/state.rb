module Stamina
  class Automaton
    #
    # Automaton state.
    #
    class State
      include Stamina::Markable
      attr_reader :automaton, :index

      #
      # Creates a state.
      #
      # Arguments:
      # - automaton: parent automaton of the state.
      # - index: index of the state in the state list.
      # - data: user data attached to this state.
      #
      def initialize(automaton, index, data)
        @automaton = automaton
        @index = index
        @data = data.dup
        @out_edges = []
        @in_edges = []
        @epsilon_closure = nil
      end

      ### public read-only section ###############################################
      public

      # Returns true if this state is an initial state, false otherwise.
      def initial?
        !!@data[:initial]
      end

      # Sets this state as an initial state.
      def initial!
        @data[:initial] = true
      end

      # Returns true if this state is an accepting state, false otherwise.
      def accepting?
        !!@data[:accepting]
      end

      # Sets this state as an accepting state.
      def accepting!
        @data[:accepting] = true
      end

      # Returns true if this state is an error state, false otherwise.
      def error?
        !!@data[:error]
      end

      # Sets this state as an error state.
      def error!
        @data[:error] = true
      end

      # Returns true if this state is deterministic, false otherwise.
      def deterministic?
        outs = out_symbols
        (outs.size==@out_edges.size) and not(outs.include?(nil))
      end

      # Checks if this state is a sink state or not. Sink states are defined as
      # non accepting states having no outgoing transition or only loop
      # transitions.
      def sink?
        !accepting? && out_edges.all?{|e| e.target==self}
      end

      # Returns an array containing all incoming edges of the state. Edges are
      # sorted if _sorted_ is set to true. If two incoming edges have same symbol
      # no order is guaranteed between them.
      #
      # Returned array may be modified.
      def in_edges(sorted=false)
        sorted ? @in_edges.sort : @in_edges.dup
      end

      # Returns an array containing all outgoing edges of the state. Edges are
      # sorted if _sorted_ is set to true. If two outgoing edges have same symbol
      # no order is guaranteed between them.
      #
      # Returned array may be modified.
      def out_edges(sorted=false)
        sorted ? @out_edges.sort : @out_edges.dup
      end

      # Returns an array with the different symbols appearing on incoming edges.
      # Returned array does not contain duplicates. Symbols are sorted in the
      # array if _sorted_ is set to true.
      #
      # Returned array may be modified.
      def in_symbols(sorted=false)
        symbols = @in_edges.collect{|e| e.symbol}.uniq
        return sorted ? (symbols.sort &automaton.symbols_comparator) : symbols
      end

      # Returns an array with the different symbols appearing on outgoing edges.
      # Returned array does not contain duplicates. Symbols are sorted in the
      # array if _sorted_ is set to true.
      #
      # Returned array may be modified.
      def out_symbols(sorted=false)
        symbols = @out_edges.collect{|e| e.symbol}.uniq
        return sorted ? (symbols.sort &automaton.symbols_comparator) : symbols
      end

      # Returns an array with adjacent states (in or out edge).
      #
      # Returned array may be modified.
      def adjacent_states()
        (in_adjacent_states+out_adjacent_states).uniq
      end

      # Returns an array with adjacent states along an incoming edge (without
      # duplicates).
      #
      # Returned array may be modified.
      def in_adjacent_states()
        (@in_edges.collect {|e| e.source}).uniq
      end

      # Returns an array with adjacent states along an outgoing edge (whithout
      # duplicates).
      #
      # Returned array may be modified.
      def out_adjacent_states()
        (@out_edges.collect {|e| e.target}).uniq
      end

      # Returns reachable states from this one with an input _symbol_. Returned
      # array does not contain duplicates and may be modified. This method if not
      # epsilon symbol aware.
      def step(symbol)
        @out_edges.select{|e| e.symbol==symbol}.collect{|e| e.target}
      end

      # Returns the state reached from this one with an input _symbol_, or nil if
      # no such state. This method is not epsilon symbol aware. Moreover it is
      # expected to be used on deterministic states only. If the state is not
      # deterministic, the method returns one reachable state if such a state
      # exists; which one is returned must be considered non deterministic.
      def dfa_step(symbol)
        edge = @out_edges.find{|e| e.symbol==symbol}
        edge ? edge.target : nil
      end

      # Computes the epsilon closure of this state. Epsilon closure is the set of
      # all states reached from this one with a <tt>eps*</tt> input (sequence of
      # zero or more epsilon symbols). The current state is always contained in
      # the epsilon closure. Returns an unsorted array without duplicates; this
      # array may not be modified.
      def epsilon_closure()
        @epsilon_closure ||= compute_epsilon_closure(Set.new).to_a.freeze
      end

      # Internal implementation of epsilon_closure. _result_ is expected to be
      # a Set instance, is modified and is the returned value.
      def compute_epsilon_closure(result)
        result << self
        step(nil).each do |t|
          t.compute_epsilon_closure(result) unless result.include?(t)
        end
        raise if result.nil?
        return result
      end

      # Computes an array representing the set of states that can be reached from
      # this state with a given input _symbol_. Returned array does not contain
      # duplicates and may be modified. No particular ordering of states in the
      # array is guaranteed.
      #
      # This method is epsilon symbol aware (represented with nil) on non
      # deterministic automata, meaning that it actually computes the set of
      # reachable states through strings respecting the <tt>eps* symbol eps*</tt>
      # regular expression, where eps is the epsilon symbol.
      def delta(symbol)
        if automaton.deterministic?
          target = dfa_delta(symbol)
          target.nil? ? [] : [target]
        else
          at_epsilon = epsilon_closure
          at_espilon_then_symbol = at_epsilon.map{|s| s.step(symbol)}.flatten.uniq
          at_espilon_then_symbol.map{|s| s.epsilon_closure}.flatten.uniq
        end
      end

      # Returns the target state that can be reached from this state with _symbol_
      # input. Returns nil if no such state exists.
      #
      # This method is expected to be used on deterministic automata. Unlike delta,
      # it returns a State instance (or nil), not an array of states. When used on
      # non deterministic automata, it returns a state immediately reachable from
      # this state with _symbol_ input, or nil if no such state exists. This
      # method is not epsilon aware.
      def dfa_delta(symbol)
        return nil if symbol.nil?
        edge = @out_edges.find{|e| e.symbol==symbol}
        edge.nil? ? nil : edge.target
      end

      # Provides comparator of states, based on the index in the automaton state
      # list. This method returns nil unless  _o_ is a State from the same
      # automaton than self.
      def <=>(o)
        return nil unless State===o
        return nil unless automaton===o.automaton
        return index <=> o.index
      end

      # Returns a string representation
      def inspect
        's' << @index.to_s
      end

      # Returns a string representation
      def to_s
        's' << @index.to_s
      end

      ### protected write section ################################################
      protected

      # Changes the index of this state in the state list. This method is only
      # expected to be used by the automaton itself.
      def index=(i) @index=i end

      #
      # Fired by Loaded when a user data is changed. The message is forwarded to
      # the automaton.
      #
      def state_changed(what, description)
        @epsilon_closure = nil
        @automaton.send(:state_changed, what, description)
      end

      # Adds an incoming edge to the state.
      def add_incoming_edge(edge)
        @epsilon_closure = nil
        @in_edges << edge
      end

      # Adds an outgoing edge to the state.
      def add_outgoing_edge(edge)
        @epsilon_closure = nil
        @out_edges << edge
      end

      # Adds an incoming edge to the state.
      def drop_incoming_edge(edge)
        @epsilon_closure = nil
        @in_edges.delete(edge)
      end

      # Adds an outgoing edge to the state.
      def drop_outgoing_edge(edge)
        @epsilon_closure = nil
        @out_edges.delete(edge)
      end

      protected :compute_epsilon_closure
    end # class State
  end # class Automaton
end # module Stamina