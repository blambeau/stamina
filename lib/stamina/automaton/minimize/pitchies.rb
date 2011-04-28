module Stamina
  class Automaton
    module Minimize
      class Pitchies

        # Creates an algorithm instance
        def initialize(automaton, options)
          raise ArgumentError, "Deterministic automaton expected", caller unless automaton.deterministic?
          @automaton = automaton
        end
        
        def minimized_dfa(oldfa, nb_states, partition)
          Automaton.new(false) do |newfa| 
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
          Pitchies.new(automaton.complete, options).main
        end
      
      end # class Pitchies
    end # module Minimize
  end # class Automaton
end # module Stamina

