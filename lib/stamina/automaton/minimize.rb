module Stamina
  class Automaton
    
    #
    # Checks if this automaton is minimal.
    #
    def minimal?
      self.minimize <=> self.complement
    end
      
    #
    # Returns a minimized version of this automaton.
    #
    # This method should only be called on deterministic automata.
    #
    def minimize(options = {})
      Minimizer.execute(self, options)
    end

    #
    # Implements Hopcroft's algorithm for minimizing deterministic automata
    #.
    class Minimizer
      
      # Creates an algorithm instance
      def initialize(automaton, options)
        raise ArgumentError, "Deterministic automaton expected", caller unless automaton.deterministic?
        @automaton = automaton
      end
      
      # Compute a Hash {symbol => state_group} from a group of states
      def reverse_delta(group)
        h = Hash.new{|h,k| h[k]=Set.new}
        group.each do |state|
          state.in_edges.each do |edge|
            h[edge.symbol] << edge.source
          end
        end
        h
      end
      
      # Computes a minimal dfa from the grouping information
      def compute_minimal_dfa(groups)
        indexes = []
        Automaton.new do |fa|

          # create one state for each group
          groups.each_with_index do |group,index|
            group.each{|s| indexes[s.index] = index}
            data = group.inject(nil) do |memo,s|
              if memo.nil?
                s.data
              else
                {:initial   => memo[:initial]   || s.initial?,
                 :accepting => memo[:accepting] || s.accepting?,
                 :error     => memo[:error]     || s.error?}
              end
            end
            fa.add_state(data)
          end

          # connect transitions now
          groups.each_with_index do |group,index|
            group.each do |s|
              s_index = indexes[s.index]
              s.out_edges.each do |edge|
                symbol, t_index = edge.symbol, indexes[edge.target.index]
                unless fa.ith_state(s_index).dfa_step(symbol)
                  fa.connect(s_index, t_index, symbol)
                end
              end
            end
          end

        end
      end
      
      # Computes the initial partition
      def initial_partition
        p = [Set.new, Set.new]
        @automaton.states.each do |s|
          (s.accepting? ? p[0] : p[1]) << s
        end
        p.reject{|g| g.empty?}
      end
      
      # Main method of the algorithm
      def main
        # Partition states a first time according to accepting/non accepting
        @blocks = initial_partition # P in pseudo code
        @to_refine = @blocks.dup    # W in pseudo code
        
        # Until a block needs to be refined
        until @to_refine.empty?
          refined = @to_refine.pop
          
          # We compute the reverse delta on the group and look at the groups
          rdelta = reverse_delta(refined)
          rdelta.each_pair do |symbol, sources| # sources is la in pseudo code
            
            # Find blocks to be refined
            @blocks.dup.each_with_index do |block, index| # block is R in pseudo code
              next if block.subset?(sources)
              intersection = block & sources    # R1 in pseudo code
              next if intersection.empty?
              difference = block - intersection # R2 in pseudo code
              
              # replace R in P with R1 and R2
              @blocks[index] = intersection
              @blocks << difference
              
              # Adds the new blocks as to be refined
              if @to_refine.include?(block)
                @to_refine.delete(block)
                @to_refine << intersection << difference
              else
                @to_refine << (intersection.size <= difference.size ? intersection : difference)
              end
            end # @blocks.each
            
          end # rdelta.each_pair
        end # until @to_refine.empty?
        
        compute_minimal_dfa(@blocks)
      end # def main
      
      # Execute the minimizer
      def self.execute(automaton, options={})
        Minimizer.new(automaton.complement, options).main
      end
      
    end # class Minimizer

  end # class Automaton
end # module Stamina
