require 'stamina/utils/decorate'
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
        algo = Stamina::Utils::Decorate.new(key)
        algo.set_suppremum do |d0,d1|
          if d0.nil?
            d1
          elsif d1.nil?
            d0
          else
            (d0 <= d1 ? d0 : d1)
          end
        end
        algo.set_propagate {|d,e| d+1 }
        algo.execute(self, nil, 0)
        states.max{|s0,s1| s0[:depth] <=> s1[:depth]}[:depth]
      end
      
    end # module Metrics
    include Metrics
  end # class Automaton
end # module Stamina
