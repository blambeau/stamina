module Stamina
  class Automaton
    module Minimize
      #
      # Straightforward and simple to understand minimization algorithm.
      #
      # The principle of the algorithm is to successively refine a partition of
      # the DFA states. This partition is represented by an array of integers,
      # one for each state, that uniquely identifies the partition block to which
      # the state belongs. As usual, the initial partition separates accepting
      # from non accepting states:
      #
      #   P0 = [0, 1, 0, 0, ..., 1]  # N integers, 1 (resp. 0) for accepting (resp
      #                              # non accepting) states.
      #
      # A refinement step of the algorithm consists in refining this partition by
      # looking forward in the DFA for each symbol in the alphabet. Consider a given
      # symbol, say 'a', and the transition function given by a (complete) DFA. We
      # can represent the restriction of this function over a given symbol, say 'a'
      # by a simple array, containing the target state reached through 'a' for each
      # state of the DFA:
      #
      #   DELTA('a') = [5, 7, 1, ..., 0] # N integers, containing the unique identifier
      #                                  # of the target state reached through 'a' from
      #                                  # each state of the DFA, in order
      #
      # Now, given a partition of the DFA states Pi, one can simply look which block
      # of the partition is reached through a given letter, say 'a' by combining it
      # with DELTA('a')
      #
      #   REACHED(Pi, 'a') = [ Pi[DELTA('a')[j]] | foreach 0 <= j < N-1 ]
      #
      # Given a partition Pi, if two states in the same block reach different blocks
      # along the same symbol, they must be separated, by definition. Interrestingly,
      # this information is contained in pairs of integers given by Pi and REACHED(Pi, 'a').
      # In other words, consider the pairs
      #
      #   PAIRS(Pi, 'a') = [ (Pi[j], REACHED(Pi, 'a')[j]) | foreach 0 <= j < N-1 ]
      #
      # Now, without loss of generality, one can simply give a unique number to each
      # different pair in such an array of pairs (a naïve way of doing so is to define
      # a total order relation over pairs, sorting them, and taking the smallest index
      # of each pair in the sorted array). This leads to a partition refinement:
      #
      #   REFINEMENT(Pi, 'a') = [ unique-number-of(PAIRS(Pi, 'a')[j]) | foreach 0 <= j < N-1 ]
      #
      # A step of the algorithm consists in applying such a refinement for each symbol in
      # the alphabet:
      #
      #   foreach symbol in Sigma
      #     Pi = REFINEMENT(Pi, symbol)
      #
      # The algorithm applies such refinements until a fix point is reached:
      #
      #   # Trivial partition with all states in same block
      #   Pi = [ 0 | foreach 0 <= j < N-1 ]
      #
      #   # initial non trivial partition separating accepting for non accepting
      #   # states
      #   Pj = [...]
      #
      #   # fixpoint loop until Pi == Pj, i.e. no change has been made
      #   while Pj != Pi   # warning here, we compare the real partitions...
      #     Pi = Pj
      #     foreach symbol in Sigma
      #       Pj = REFINEMENT(Pj, symbol)
      #   end
      #
      class Pitchies

        # Creates an algorithm instance
        def initialize(automaton, options)
          raise ArgumentError, "Deterministic automaton expected", caller unless automaton.deterministic?
          @automaton = automaton
        end

        def minimized_dfa(oldfa, nb_states, partition)
          fa = Automaton.new(false) do |newfa|
            # Add the number of states, with default marks
            newfa.add_n_states(nb_states, {:initial => false, :accepting => false, :error => false})

            # Refine the marks using the source dfa as reference
            partition.each_with_index do |block, state_index|
              source = oldfa.ith_state(state_index)
              target = newfa.ith_state(block)
              target.initial!   if source.initial?
              target.accepting! if source.accepting?
              target.error!     if source.error?
            end

            # Now, create the transitions
            partition.each_with_index do |block, state_index|
              source = oldfa.ith_state(state_index)
              target = newfa.ith_state(block)
              source.out_edges.each do |edge|
                where = partition[edge.target.index]
                if target.dfa_step(edge.symbol) == nil
                  newfa.connect(target, where, edge.symbol)
                end
              end
            end
          end
          fa.drop_states *fa.states.select{|s| s.sink?}
          fa.state_count == 0 ? Automaton::DUM : fa
        end

        def main
          alph, states = @automaton.alphabet, @automaton.states
          old_nb_states = -1
          partition = states.collect{|s| s.accepting? ? 1 : 0}
          until (nb_states = partition.uniq.size) == old_nb_states
            old_nb_states = nb_states
            alph.each do |symbol|
              reached = states.collect{|s| partition[s.dfa_step(symbol).index]}
              rehash = Hash.new{|h,k| h[k] = h.size}
              partition = partition.zip(reached).collect{|pair| rehash[pair]}
            end
          end
          minimized_dfa(@automaton, nb_states, partition)
        end

        # Execute the minimizer
        def self.execute(automaton, options={})
          Pitchies.new(automaton.strip.complete!, options).main
        end

      end # class Pitchies
    end # module Minimize
  end # class Automaton
end # module Stamina