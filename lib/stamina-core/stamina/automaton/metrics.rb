module Stamina
  class Automaton
    #
    # Provides useful metric methods on automata.
    #
    # This module is automatically included by Automaton and is not intended
    # to be used directly.
    #
    module Metrics

      #
      # Returns the number of letters of the alphabet.
      #
      def alphabet_size
        alphabet.size
      end

      #
      # Returns the average degree of states, that is,
      # <code>edge_count/state_count</code>
      #
      def avg_degree
        edge_count.to_f/state_count.to_f
      end
      alias :avg_out_degree :avg_degree
      alias :avg_in_degree :avg_degree

      #
      # Number of accepting states over all states
      #
      def accepting_ratio
        states.select{|s|s.accepting?}.size.to_f/state_count.to_f
      end

      #
      # Number of error states over all states
      #
      def error_ratio
        states.select{|s|s.error?}.size.to_f/state_count.to_f
      end

      #
      # Computes the depth of the automaton.
      #
      # The depth of an automaton is defined as the length of the longest shortest
      # path from the initial state to a state.
      #
      # This method has a side effect on state marks, as it keeps the depth of
      # each state as a mark under _key_, which defaults to :depth.
      #
      def depth(key = :depth)
        algo = Stamina::Utils::Decorate.new
        algo.set_suppremum do |d0,d1|
          # Unreached state is MAX (i.e. nil is +INF); we look at the min depth for each state
          (d0.nil? or d1.nil?) ? (d0 || d1) : (d0 <= d1 ? d0 : d1)
        end
        algo.set_propagate{|d,e| d+1 }
        algo.set_initiator{|s| s.initial? ? 0 : nil }
        algo.set_start_predicate{|s| s.initial? }
        algo.call(self, key)
        deepest = states.max do |s0,s1|
          # do not take unreachable states into account: -1 is taken if nil is encountered
          (s0[:depth] || -1) <=> (s1[:depth] || -1)
        end
        deepest[:depth]
      end

    end # module Metrics
    include Metrics
  end # class Automaton
end # module Stamina